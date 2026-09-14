# E-commerce — test cases

165 cases across a self-written mini-shop (with a real SQLite database) and the live automationexercise.com. Generated from `../features/*.feature` by `build.js`; do not edit by hand.

## minishop-db (30)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 1 | BE/DB | High | The store has the documented tables |
| 2 | BE/DB | High | A product SKU is unique |
| 3 | BE/DB | High | Order lines reference a real order and a real product |
| 4 | BE/DB | High | Amounts and quantities are bounded by CHECK |
| 5 | BE/DB | Medium | A stock movement is a real, non-zero change with a known reason |
| 6 | BE/DB | Medium | Seeding twice leaves the same rows |
| 7 | BE/DB | High | A checkout creates an order whose total equals the sum of its lines |
| 8 | BE/DB | High | Order lines capture the price at purchase |
| 9 | BE/DB | High | Checkout decrements stock by the ordered quantity |
| 10 | BE/DB | High | Checkout records a matching stock movement |
| 11 | BE/DB | High | The stock ledger balances against the running stock |
| 12 | BE/DB | High | An oversell is refused and leaves the store untouched |
| 13 | BE/DB | Medium | An empty cart cannot be checked out |
| 14 | BE/DB | Medium | A checked-out cart is marked so |
| 15 | BE/DB | Medium | The order belongs to the buyer who placed it |
| 16 | BE/DB | Medium | One order line per distinct cart line |
| 17 | BE/DB | High | A percentage coupon is applied to the order |
| 18 | BE/DB | High | A coupon redemption is counted exactly once |
| 19 | BE/DB | High | A single-redemption coupon cannot be spent twice |
| 20 | BE/DB | High | A repeated checkout with the same idempotency key makes one order |
| 21 | BE/DB | Medium | No order line references a missing product |
| 22 | BE/DB | Medium | No order references a missing cart |
| 23 | BE/DB | Medium | The subtotal on the order equals the sum of quantity times price |
| 24 | BE/DB | Medium | The order total equals subtotal minus discount |
| 25 | BE/DB | High | Stock never runs negative across repeated checkouts |
| 26 | BE/DB | Medium | Checkout of <sym> decrements its stock and records a movement |
| 27 | BE/DB | Medium | Checkout of <sym> decrements its stock and records a movement |
| 28 | BE/DB | Medium | Checkout of <sym> decrements its stock and records a movement |
| 29 | BE/DB | Medium | Adding to a cart writes a cart line |
| 30 | BE/DB | Medium | A seeded product's ledger balances from the start |

## minishop-api (35)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 31 | BE/API | High | /products returns the active products, priced from the rows |
| 32 | BE/API | High | /products paginates without repeating or dropping a row |
| 33 | BE/API | Medium | /products total counts the whole active set, not the page |
| 34 | BE/API | Medium | /products can be filtered by category |
| 35 | BE/API | Medium | /products can be sorted by price |
| 36 | BE/API | Low | /products rejects a bad page or limit |
| 37 | BE/API | High | /products/:id returns the row, and hides an inactive product |
| 38 | BE/API | Medium | /categories returns every category row |
| 39 | BE/API | High | /search matches names and never returns an inactive product |
| 40 | BE/API | Low | /search requires a query |
| 41 | BE/API | High | A new cart is empty with a zero subtotal |
| 42 | BE/API | High | Adding an item reflects the row and the line total |
| 43 | BE/API | Medium | Adding the same product twice merges into one line |
| 44 | BE/API | High | A quantity beyond stock is refused |
| 45 | BE/API | Medium | Setting a line quantity to zero removes it |
| 46 | BE/API | Low | An unknown product cannot be added |
| 47 | BE/API | Low | An inactive product cannot be added |
| 48 | BE/API | Low | A non-positive quantity is rejected |
| 49 | BE/API | Medium | The cart subtotal always equals the sum of its lines |
| 50 | BE/API | Low | An unknown cart is 404 |
| 51 | BE/API | High | A percentage coupon returns the right discount |
| 52 | BE/API | High | A fixed coupon below its minimum spend is refused |
| 53 | BE/API | Medium | A fixed coupon at or above its minimum spend applies |
| 54 | BE/API | Medium | An inactive coupon is refused |
| 55 | BE/API | Low | An unknown coupon is 404 |
| 56 | BE/API | Medium | A discount never exceeds the subtotal |
| 57 | BE/API | High | Registration issues a token; the email cannot be reused |
| 58 | BE/API | High | Login returns a token for the right password and 401 otherwise |
| 59 | BE/API | High | Checkout requires a token |
| 60 | BE/API | High | A checkout returns an order equal to the stored order |
| 61 | BE/API | High | The order response total equals the sum of its line amounts |
| 62 | BE/API | High | GET /orders/:id returns the order to its owner and 403 to anyone else |
| 63 | BE/API | Medium | An unauthenticated order read is 401 |
| 64 | BE/API | Medium | A retried checkout with the same idempotency key returns the same order |
| 65 | BE/API | Low | A consistent error shape and a 404 for unknown routes |

## site-api (30)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 66 | BE/API | High | The product list answers 200 and is non-empty |
| 67 | BE/API | High | Every product has a unique id |
| 68 | BE/API | High | Every product price parses as a non-negative amount |
| 69 | BE/API | Medium | Every product carries a name, brand and category |
| 70 | BE/API | Low | The product list rejects POST as an unsupported method |
| 71 | BE/API | High | The brand list answers 200 and is non-empty |
| 72 | BE/API | Medium | Every brand has an id and a name |
| 73 | BE/API | Low | The brand list rejects POST |
| 74 | BE/API | High | Searching for "<term>" returns a non-empty subset of the catalogue |
| 75 | BE/API | High | Searching for "<term>" returns a non-empty subset of the catalogue |
| 76 | BE/API | High | Searching for "<term>" returns a non-empty subset of the catalogue |
| 77 | BE/API | Medium | A search with no term is a bad request |
| 78 | BE/API | Low | A search that matches nothing returns an empty list, not an error |
| 79 | BE/API | High | verifyLogin without credentials is a bad request |
| 80 | BE/API | Medium | verifyLogin for an unregistered email is not found |
| 81 | BE/API | Low | verifyLogin rejects DELETE |
| 82 | BE/API | Medium | An unknown user detail lookup is not found |
| 83 | BE/API | Medium | The product list and search draw from the same catalogue |
| 84 | BE/API | Medium | Every product category names a user type |
| 85 | BE/API | Low | The product list is stable across two reads |
| 86 | BE/API | Medium | Brand ids are unique |
| 87 | BE/API | Low | Every product id is a positive integer |
| 88 | BE/API | Low | The response body is well-formed JSON with a numeric response code |
| 89 | BE/API | Medium | The search for "<term>" is a subset of the catalogue by count |
| 90 | BE/API | Medium | The search for "<term>" is a subset of the catalogue by count |
| 91 | BE/API | Medium | The search for "<term>" is a subset of the catalogue by count |
| 92 | BE/API | Low | Prices are quoted in the documented "Rs. N" form |
| 93 | BE/API | Low | Every brand name is trimmed and non-empty |
| 94 | BE/API | Medium | A case-insensitive search still matches |
| 95 | BE/API | Low | The catalogue has at least a dozen products |

## minishop-fe (30)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 96 | FE/UI | High | The catalogue lists exactly the active products |
| 97 | FE/UI | High | Every catalogue price on screen matches its row |
| 98 | FE/UI | High | The out-of-stock product is labelled out of stock |
| 99 | FE/UI | Medium | In-stock products are labelled in stock |
| 100 | FE/UI | Medium | The inactive product does not appear on the catalogue |
| 101 | FE/UI | High | A product page shows the name, price and SKU from the row |
| 102 | FE/UI | Medium | A product page shows the stock level from the row |
| 103 | FE/UI | Medium | An unknown product page is not found |
| 104 | FE/UI | Medium | The out-of-stock product page says so |
| 105 | FE/UI | High | An order page shows the total the order was placed at |
| 106 | FE/UI | Medium | An order page shows the order id and a placed status |
| 107 | FE/UI | Medium | The catalogue price format is a dollar amount |
| 108 | FE/UI | Low | The catalogue is not empty |
| 109 | FE/UI | Medium | Each catalogue name matches its product row |
| 110 | FE/UI | Low | An unknown order page is not found |
| 111 | FE/UI | Medium | The product page for <pid> matches its row |
| 112 | FE/UI | Medium | The product page for <pid> matches its row |
| 113 | FE/UI | Medium | The product page for <pid> matches its row |
| 114 | FE/UI | Medium | <label> product's price on the catalogue equals its row |
| 115 | FE/UI | Medium | <label> product's price on the catalogue equals its row |
| 116 | FE/UI | Medium | <label> product's price on the catalogue equals its row |
| 117 | FE/UI | Medium | The catalogue product count equals the active count in the API |
| 118 | FE/UI | Low | The product page price format is a dollar amount |
| 119 | FE/UI | Low | A product page name is non-empty |
| 120 | FE/UI | Medium | The order page total is a dollar amount |
| 121 | FE/UI | Low | The catalogue links each product to its own page |
| 122 | FE/UI | Medium | A discounted order page shows the discounted total |
| 123 | FE/UI | Low | Every catalogue stock label is one of two known values |
| 124 | FE/UI | Medium | The product page SKU matches its row exactly |
| 125 | FE/UI | Low | The catalogue product ids are unique on screen |

## site-fe (30)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 126 | FE/UI | High | The storefront shows as many products as the API lists |
| 127 | FE/UI | High | Every product on screen carries a name and a price |
| 128 | FE/UI | High | Every price on screen is in the "Rs. N" form |
| 129 | FE/UI | Medium | Every product name on screen is one the API knows |
| 130 | FE/UI | Medium | The first product on screen matches the API's first product |
| 131 | FE/UI | Medium | The storefront shows at least a dozen products |
| 132 | FE/UI | Low | No product card is missing its price |
| 133 | FE/UI | Low | No product card is missing its name |
| 134 | FE/UI | Medium | Product names on screen have no duplicates beyond the API's |
| 135 | FE/UI | Medium | Every price on screen parses to a non-negative number |
| 136 | FE/UI | High | A search on screen returns a non-empty grid |
| 137 | FE/UI | High | A search on screen returns no more products than the catalogue |
| 138 | FE/UI | Medium | Every search result name is one the API knows |
| 139 | FE/UI | Medium | A search that matches nothing shows an empty grid, not an error |
| 140 | FE/UI | Low | Search prices are also in the "Rs. N" form |
| 141 | FE/UI | Medium | Searching the storefront for "<term>" agrees with the API count |
| 142 | FE/UI | Medium | Searching the storefront for "<term>" agrees with the API count |
| 143 | FE/UI | Medium | Searching the storefront for "<term>" agrees with the API count |
| 144 | FE/UI | Medium | A case-different search returns the same count on screen |
| 145 | FE/UI | High | The brand rail lists the brands the API knows |
| 146 | FE/UI | Medium | The brand rail is non-empty |
| 147 | FE/UI | Low | The brand rail has no blank entries |
| 148 | FE/UI | Medium | The product count on screen is stable across two loads |
| 149 | FE/UI | Low | Every product card price has a rupee symbol |
| 150 | FE/UI | Medium | The screen's product names are a subset of the API's names |
| 151 | FE/UI | Low | The grid shows unique product names in its first page |
| 152 | FE/UI | Medium | The most expensive on-screen price is a real API price |
| 153 | FE/UI | Low | The cheapest on-screen price is a real API price |
| 154 | FE/UI | Medium | A search result count never exceeds the full grid count |
| 155 | FE/UI | Low | The products page has a heading |

## minishop-security (10)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 156 | BE/API | High | A checkout with a forged token is refused |
| 157 | BE/API | High | A checkout with a tampered token is refused |
| 158 | BE/API | High | An order read with a forged token is refused |
| 159 | BE/API | High | Login reveals nothing about whether an email exists |
| 160 | BE/API | High | An account locks after too many failed logins |
| 161 | BE/API | High | A locked account is refused even with the correct password |
| 162 | BE/API | Medium | A successful login clears the failed-login counter |
| 163 | BE/API | High | Registration issues a token but never the password hash |
| 164 | BE/API | High | Login never carries the password hash |
| 165 | BE/API | Medium | A product listing leaks no credential |
