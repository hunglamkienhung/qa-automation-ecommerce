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
| 346 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 347 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 348 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 349 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 350 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 351 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 352 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 353 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 354 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 355 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 356 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 357 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 358 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 359 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 360 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 361 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 362 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 363 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 364 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 365 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 366 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 367 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 368 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 369 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 370 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 371 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 372 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 373 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 374 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 375 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 376 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 377 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 378 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 379 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 380 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 381 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 382 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 383 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 384 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 385 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 386 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 387 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 388 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 389 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 390 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 391 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 392 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 393 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 394 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 395 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 396 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 397 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 398 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 399 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 400 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 401 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 402 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 403 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 404 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 405 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 406 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 407 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 408 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 409 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 410 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 411 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 412 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 413 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 414 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 415 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 416 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 417 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 418 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 419 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 420 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 421 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 422 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 423 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 424 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 425 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 426 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 427 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 428 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 429 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 430 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 431 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 432 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 433 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 434 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 435 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 436 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 437 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 438 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 439 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 440 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 441 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 442 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 443 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 444 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 445 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 446 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 447 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 448 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 449 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 450 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 451 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 452 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 453 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 454 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 455 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 456 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 457 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 458 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 459 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 460 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 461 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 462 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 463 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 464 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 465 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 466 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 467 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 468 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 469 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 470 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 471 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 472 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 473 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 474 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 475 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 476 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 477 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 478 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 479 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 480 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 481 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 482 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 483 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 484 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 485 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 486 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 487 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 488 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 489 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 490 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 491 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 492 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 493 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 494 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 495 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 496 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 497 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 498 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 499 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 500 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 501 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 502 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 503 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 504 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 505 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 506 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 507 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 508 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 509 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 510 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 511 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 512 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 513 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 514 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 515 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 516 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 517 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 518 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 519 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 520 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 521 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 522 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 523 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 524 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 525 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 526 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 527 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 528 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 529 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 530 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 531 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 532 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 533 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 534 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 535 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 536 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 537 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 538 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 539 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 540 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 541 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 542 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 543 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 544 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 545 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 546 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 547 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 548 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 549 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 550 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 551 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 552 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 553 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 554 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 555 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 556 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 557 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 558 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 559 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 560 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 561 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 562 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 563 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 564 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 565 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 566 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 567 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 568 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 569 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 570 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 571 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 572 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 573 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 574 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 575 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 576 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 577 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 578 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 579 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 580 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 581 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 582 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 583 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 584 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 585 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 586 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 587 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 588 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 589 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 590 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 591 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 592 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 593 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 594 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 595 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 596 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 597 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 598 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 599 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 600 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 601 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 602 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 603 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 604 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 605 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 606 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 607 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 608 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 609 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 610 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 611 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 612 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 613 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 614 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 615 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 616 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 617 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 618 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 619 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 620 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 621 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 622 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 623 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 624 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 625 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 626 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 627 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 628 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 629 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 630 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 631 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 632 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 633 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 634 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 635 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 636 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 637 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 638 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 639 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 640 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 641 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 642 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 643 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 644 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 645 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 646 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 647 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 648 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 649 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 650 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 651 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 652 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 653 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 654 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 655 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 656 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 657 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 658 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 659 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 660 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 661 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 662 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 663 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 664 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 665 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 666 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 667 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 668 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 669 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 670 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 671 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 672 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 673 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 674 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 675 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 676 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 677 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 678 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 679 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 680 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 681 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 682 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 683 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 684 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 685 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 686 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 687 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 688 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 689 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 690 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 691 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 692 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 693 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 694 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 695 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 696 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 697 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 698 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 699 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 700 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 701 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 702 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 703 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 704 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 705 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 706 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 707 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 708 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 709 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 710 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 711 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 712 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 713 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 714 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 715 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 716 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 717 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 718 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 719 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 720 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 721 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 722 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 723 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 724 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 725 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 726 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 727 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 728 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 729 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 730 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 731 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 732 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 733 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 734 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 735 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 736 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 737 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 738 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 739 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 740 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 741 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 742 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 743 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 744 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 745 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 746 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 747 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 748 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 749 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 750 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 751 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 752 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 753 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 754 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 755 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 756 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 757 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 758 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 759 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 760 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 761 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 762 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 763 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 764 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 765 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 766 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 767 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 768 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 769 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 770 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 771 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 772 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 773 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 774 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 775 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 776 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 777 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 778 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 779 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 780 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 781 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 782 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 783 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 784 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 785 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 786 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 787 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 788 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 789 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 790 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 791 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 792 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 793 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 794 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 795 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 796 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 797 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 798 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 799 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 800 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 801 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 802 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 803 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 804 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 805 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 806 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 807 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 808 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 809 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 810 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 811 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 812 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 813 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 814 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 815 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 816 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 817 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 818 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 819 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 820 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 821 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 822 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 823 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 824 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 825 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 826 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 827 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 828 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 829 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 830 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 831 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 832 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 833 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 834 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 835 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 836 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 837 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 838 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 839 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 840 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 841 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 842 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 843 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 844 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 845 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 846 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 847 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 848 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 849 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 850 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 851 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 852 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 853 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 854 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 855 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 856 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 857 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 858 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 859 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 860 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 861 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 862 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 863 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 864 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 865 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 866 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 867 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 868 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 869 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 870 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 871 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 872 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 873 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 874 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 875 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 876 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 877 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 878 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 879 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 880 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 881 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 882 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 883 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 884 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 885 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 886 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 887 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 888 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 889 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 890 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 891 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 892 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 893 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 894 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 895 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 896 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 897 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 898 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 899 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 900 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 901 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 902 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 903 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 904 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 905 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 906 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 907 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 908 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 909 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 910 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 911 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 912 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 913 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 914 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 915 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 916 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 917 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 918 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 919 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 920 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 921 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 922 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 923 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 924 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 925 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 926 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 927 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 928 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 929 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 930 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 931 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 932 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 933 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 934 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 935 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 936 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 937 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 938 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 939 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 940 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 941 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 942 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 943 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 944 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 945 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 946 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 947 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 948 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 949 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 950 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 951 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 952 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 953 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 954 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 955 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 956 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 957 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 958 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 959 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 960 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 961 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 962 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 963 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 964 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 965 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 966 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 967 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 968 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 969 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 970 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 971 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 972 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 973 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 974 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 975 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 976 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 977 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 978 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 979 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 980 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 981 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 982 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 983 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 984 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 985 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 986 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 987 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 988 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 989 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 990 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 991 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 992 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 993 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 994 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 995 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 996 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 997 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 998 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 999 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |
| 1000 | BE/API | Medium | A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals |

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
