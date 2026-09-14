# E-commerce — test cases

1000 cases across a self-written mini-shop (with a real SQLite database) and the live automationexercise.com. Generated from `../features/*.feature` by `build.js`; do not edit by hand.

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

## minishop-api (870)

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
| 166 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 167 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 168 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 169 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 170 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 171 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 172 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 173 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 174 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 175 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 176 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 177 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 178 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 179 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 180 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 181 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 182 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 183 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 184 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 185 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 186 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 187 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 188 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 189 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 190 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 191 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 192 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 193 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 194 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 195 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 196 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 197 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 198 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 199 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 200 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 201 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 202 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 203 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 204 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 205 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 206 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 207 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 208 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 209 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 210 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 211 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 212 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 213 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 214 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 215 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 216 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 217 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 218 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 219 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 220 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 221 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 222 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 223 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 224 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 225 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 226 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 227 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 228 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 229 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 230 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 231 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 232 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 233 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 234 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 235 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 236 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 237 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 238 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 239 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 240 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 241 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 242 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 243 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 244 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 245 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 246 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 247 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 248 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 249 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 250 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 251 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 252 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 253 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 254 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 255 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 256 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 257 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 258 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 259 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 260 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 261 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 262 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 263 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 264 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 265 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 266 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 267 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 268 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 269 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 270 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 271 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 272 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 273 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 274 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 275 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 276 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 277 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 278 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 279 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 280 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 281 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 282 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 283 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 284 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 285 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 286 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 287 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 288 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 289 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 290 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 291 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 292 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 293 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 294 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 295 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 296 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 297 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 298 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 299 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 300 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 301 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 302 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 303 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 304 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 305 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 306 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 307 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 308 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 309 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 310 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 311 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 312 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 313 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 314 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 315 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 316 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 317 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 318 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 319 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 320 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 321 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 322 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 323 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 324 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 325 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 326 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 327 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 328 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 329 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 330 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 331 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 332 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 333 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 334 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 335 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 336 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 337 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 338 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 339 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 340 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 341 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 342 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 343 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 344 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 345 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 346 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 347 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 348 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 349 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 350 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 351 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 352 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 353 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 354 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 355 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 356 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 357 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 358 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 359 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 360 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 361 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 362 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 363 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 364 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 365 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 366 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 367 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 368 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 369 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 370 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 371 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 372 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 373 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 374 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 375 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 376 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 377 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 378 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 379 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 380 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 381 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 382 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 383 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 384 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 385 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 386 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 387 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 388 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 389 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 390 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 391 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 392 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 393 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 394 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 395 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 396 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 397 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 398 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 399 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 400 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 401 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 402 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 403 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 404 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 405 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 406 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 407 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 408 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 409 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 410 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 411 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 412 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 413 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 414 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 415 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 416 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 417 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 418 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 419 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 420 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 421 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 422 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 423 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 424 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 425 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 426 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 427 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 428 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 429 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 430 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 431 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 432 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 433 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 434 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 435 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 436 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 437 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 438 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 439 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 440 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 441 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 442 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 443 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 444 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 445 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 446 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 447 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 448 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 449 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 450 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 451 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 452 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 453 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 454 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 455 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 456 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 457 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 458 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 459 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 460 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 461 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 462 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 463 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 464 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 465 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 466 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 467 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 468 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 469 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 470 | BE/API | Medium | The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount |
| 471 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 472 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 473 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 474 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 475 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 476 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 477 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 478 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 479 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 480 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 481 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 482 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 483 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 484 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 485 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 486 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 487 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 488 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 489 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 490 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 491 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 492 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 493 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 494 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 495 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 496 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 497 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 498 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 499 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 500 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 501 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 502 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 503 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 504 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 505 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 506 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 507 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 508 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 509 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 510 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 511 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 512 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 513 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 514 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 515 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 516 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 517 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 518 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 519 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 520 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 521 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 522 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 523 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 524 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 525 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 526 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 527 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 528 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 529 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 530 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 531 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 532 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 533 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 534 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 535 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 536 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 537 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 538 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 539 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 540 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 541 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 542 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 543 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 544 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 545 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 546 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 547 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 548 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 549 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 550 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 551 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 552 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 553 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 554 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 555 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 556 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 557 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 558 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 559 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 560 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 561 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 562 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 563 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 564 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 565 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 566 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 567 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 568 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 569 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 570 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 571 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 572 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 573 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 574 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 575 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 576 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 577 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 578 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 579 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 580 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 581 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 582 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 583 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 584 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 585 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 586 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 587 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 588 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 589 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 590 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 591 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 592 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 593 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 594 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 595 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 596 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 597 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 598 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 599 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 600 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 601 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 602 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 603 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 604 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 605 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 606 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 607 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 608 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 609 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 610 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 611 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 612 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 613 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 614 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 615 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 616 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 617 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 618 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 619 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 620 | BE/API | Medium | The SAVE10 coupon on a subtotal of <subtotal> discounts <disc> |
| 621 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 622 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 623 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 624 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 625 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 626 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 627 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 628 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 629 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 630 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 631 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 632 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 633 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 634 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 635 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 636 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 637 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 638 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 639 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 640 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 641 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 642 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 643 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 644 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 645 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 646 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 647 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 648 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 649 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 650 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 651 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 652 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 653 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 654 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 655 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 656 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 657 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 658 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 659 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 660 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 661 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 662 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 663 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 664 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 665 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 666 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 667 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 668 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 669 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 670 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 671 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 672 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 673 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 674 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 675 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 676 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 677 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 678 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 679 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 680 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 681 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 682 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 683 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 684 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 685 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 686 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 687 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 688 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 689 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 690 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 691 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 692 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 693 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 694 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 695 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 696 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 697 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 698 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 699 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 700 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 701 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 702 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 703 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 704 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 705 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 706 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 707 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 708 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 709 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 710 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 711 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 712 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 713 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 714 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 715 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 716 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 717 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 718 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 719 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 720 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 721 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 722 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 723 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 724 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 725 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 726 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 727 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 728 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 729 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 730 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 731 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 732 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 733 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 734 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 735 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 736 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 737 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 738 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 739 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 740 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 741 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 742 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 743 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 744 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 745 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 746 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 747 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 748 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 749 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 750 | BE/API | Medium | The SAVE10 discount never exceeds a subtotal of <subtotal> |
| 751 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 752 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 753 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 754 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 755 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 756 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 757 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 758 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 759 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 760 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 761 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 762 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 763 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 764 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 765 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 766 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 767 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 768 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 769 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 770 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 771 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 772 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 773 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 774 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 775 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 776 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 777 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 778 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 779 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 780 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 781 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 782 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 783 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 784 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 785 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 786 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 787 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 788 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 789 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 790 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 791 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 792 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 793 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 794 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 795 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 796 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 797 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 798 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 799 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 800 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 801 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 802 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 803 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 804 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 805 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 806 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 807 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 808 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 809 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 810 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 811 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 812 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 813 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 814 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 815 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 816 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 817 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 818 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 819 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 820 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 821 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 822 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 823 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 824 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 825 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 826 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 827 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 828 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 829 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 830 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 831 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 832 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 833 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 834 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 835 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 836 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 837 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 838 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 839 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 840 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 841 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 842 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 843 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 844 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 845 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 846 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 847 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 848 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 849 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 850 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 851 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 852 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 853 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 854 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 855 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 856 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 857 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 858 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 859 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 860 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 861 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 862 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 863 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 864 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 865 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 866 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 867 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 868 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 869 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 870 | BE/API | Medium | The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused |
| 871 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 872 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 873 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 874 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 875 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 876 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 877 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 878 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 879 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 880 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 881 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 882 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 883 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 884 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 885 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 886 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 887 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 888 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 889 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 890 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 891 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 892 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 893 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 894 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 895 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 896 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 897 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 898 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 899 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 900 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 901 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 902 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 903 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 904 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 905 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 906 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 907 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 908 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 909 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 910 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 911 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 912 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 913 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 914 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 915 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 916 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 917 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 918 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 919 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 920 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 921 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 922 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 923 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 924 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 925 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 926 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 927 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 928 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 929 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 930 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 931 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 932 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 933 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 934 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 935 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 936 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 937 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 938 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 939 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 940 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 941 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 942 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 943 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 944 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 945 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 946 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 947 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 948 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 949 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 950 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 951 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 952 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 953 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 954 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 955 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 956 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 957 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 958 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 959 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 960 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 961 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 962 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 963 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 964 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 965 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 966 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 967 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 968 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 969 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 970 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 971 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 972 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 973 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 974 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 975 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 976 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 977 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 978 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 979 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 980 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 981 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 982 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 983 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 984 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 985 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 986 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 987 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 988 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 989 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 990 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 991 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 992 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 993 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 994 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 995 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 996 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 997 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 998 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 999 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |
| 1000 | BE/API | Medium | Adding <qty> of product <pid> beyond its stock is refused |

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
