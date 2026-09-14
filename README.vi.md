# qa-automation-ecommerce

Kiểm thử tự động cho một miền thương mại điện tử, dựng như một hệ thống chạy
được chứ không phải slide. Một miền mua sắm được test ở **đủ mọi tầng nó có** —
cơ sở dữ liệu, API, và màn hình — bởi **hai stack độc lập** (Node dùng Cucumber,
Python dùng pytest-bdd) cùng đọc **một** bộ Gherkin dùng chung và phải cho
**cùng một kết quả ở từng case**.

Không cần tài khoản, không cần key, không dịch vụ trả phí. Clone về là chạy.

[English](README.md) · [Kiến trúc](docs/ARCHITECTURE.md) ·
[Chấm điểm](docs/GRADING.md) · [Gherkin](docs/GHERKIN.md) · [Kịch bản demo](docs/DEMO.md)

## Hai hệ thống được test

| Hệ | Truy cập | Là gì |
|---|---|---|
| **mini-shop** | đọc + ghi, DB thật | Một cửa hàng nhỏ trong `services/mini-shop`: một file SQLite, chỉ dùng thư viện chuẩn của Node, một REST API, và các trang HTML nhỏ có nhãn cho Playwright. |
| **automationexercise.com** | chỉ đọc, chạy thật | Một storefront thật có API công khai — thế giới thật, thứ mà không ai ở đây chỉnh cho pass được. |

**165 case**, mỗi case một ID bất biến, chạy ở **cả hai** stack và đối chiếu
từng case. Mỗi tầng cửa hàng có đều được test đúng ở tầng đó:

| Tầng | Đối tượng | Số case | Ở đâu |
|---|---|---|---|
| DB | SQLite mini-shop, đọc trực tiếp | 30 | `be/db` |
| API | REST mini-shop trên SQLite đó | 35 | `be/api` |
| API | ranh giới xác thực mini-shop (security) | 10 | `be/api` |
| API | API công khai automationexercise | 30 | `be/api` |
| FE | storefront mini-shop (Playwright) | 30 | `fe/ui` |
| FE | storefront automationexercise (Playwright) | 30 | `fe/ui` |
| | **Tổng** | **165** | |

**Tầng security** dò lớp auth như kẻ tấn công: token giả hoặc bị sửa → 401; đăng
nhập brute-force **khoá tài khoản** (5 lần sai → 429, từ chối cả khi đúng mật khẩu);
đăng nhập không lộ email có tồn tại hay không (đều trả một mã `bad_credentials`); và
không response nào lộ password hash. Lockout là một **control thật** service giờ có,
thêm cùng các test chứng minh nó.

`mini-shop` là nơi có đường **ghi**: checkout là một giao dịch — đọc lại kho, từ
chối bán quá kho, chốt giá tại thời điểm mua, trừ kho kèm một dòng sổ cái tương
ứng, dùng coupon tối đa một lần, và idempotent theo key. Lược đồ ràng buộc những
gì một cửa hàng không được làm hỏng — SKU duy nhất, dòng đơn hàng phải trỏ tới
đơn và sản phẩm có thật, tiền và kho không âm. Site thật là nơi các hình dạng đó
được kiểm lại trên thứ nằm ngoài tầm chỉnh của repo này.

## Hai ý đáng một phút

**Một bộ Gherkin, hai stack, một kết quả.** `features/*.feature` dùng chung.
`node/` chạy bằng Cucumber; `python/` chạy chính các file đó bằng pytest-bdd.
Lệch kết quả ở một case tự nó là một phát hiện — logic chấm điểm đang bị hiểu
khác nhau ở hai nơi — và build đỏ vì nó.

**Failed > Blocked > Passed, và mất nguồn không bao giờ là Failed.** Một case
chỉ Failed khi một mệnh đề quan sát được và sai. Khi nguồn ngoài (site, một
service đang tắt) không tới được thì case là **Blocked**, không phải Failed —
nên mạng chập chờn không bao giờ giả dạng thành cửa hàng hỏng. Cổng CI kiểm
*hình dạng* lượt chạy so với `fixtures/expected-results.json`: đỏ cả khi Passed
hoá Failed (hồi quy) lẫn khi Failed hoá Passed (phép kiểm ngừng kiểm).

## Chạy trong 30 giây

Thứ nhanh nhất chứng minh bộ máy, không cần gì bên ngoài:

```bash
cd core/node && node --test "selftest/*.test.js"
cd ../python && pip install -e . && python -m pytest selftest -q
```

## Chạy cả bộ

Mỗi lệnh dưới đây đúng bằng thứ CI chạy (`scripts/*.sh`), nên chạy tay cũng được.

```bash
bash scripts/run-be.sh node       # hoặc: python
bash scripts/run-fe.sh node       # cài sẵn chromium
bash scripts/gate.sh node         # cả bộ, rồi kiểm hình dạng lượt chạy
```

Cần: Node ≥ 22.13 (cho `node:sqlite`) và Python ≥ 3.11. Script FE tự cài trình
duyệt. Có sẵn devcontainer trong [.devcontainer/](.devcontainer/devcontainer.json).
