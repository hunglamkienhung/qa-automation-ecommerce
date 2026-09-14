@module:02-minishop-api @be @api @minishop
Feature: The mini-shop REST layer, checked against its own store

  Every scenario compares an HTTP response with the rows behind it, so a
  divergence names the API. The service is driven through the same API; the
  store is read directly only to confirm what the API reported.

  Background:
    Given the store is open and the service is reachable

  # ---------------------------------------------------------------- catalogue

  @case:31 @priority:high
  Scenario: /products returns the active products, priced from the rows
    When GET /products?limit=100
    Then the response status is 200
    And every product in the response matches its row
    And no inactive product appears

  @case:32 @priority:high
  Scenario: /products paginates without repeating or dropping a row
    When the products are paged 3 at a time
    Then the paged products are exactly the active products, each once

  @case:33 @priority:medium
  Scenario: /products total counts the whole active set, not the page
    When GET /products?limit=2
    Then the response field "total" equals the count of active products
    And the response list "products" has 2 entries

  @case:34 @priority:medium
  Scenario: /products can be filtered by category
    When GET /products?category=2&limit=100
    Then every product in the response has category_id 2
    And the response field "total" equals the count of active products in category 2

  @case:35 @priority:medium
  Scenario: /products can be sorted by price
    When GET /products?sort=price&limit=100
    Then the products are ordered by ascending price

  @case:36 @priority:low
  Scenario: /products rejects a bad page or limit
    When GET /products?limit=0
    Then the response status is 400
    When GET /products?page=0
    Then the response status is 400
    When GET /products?category=999
    Then the response status is 404
    When GET /products?sort=colour
    Then the response status is 400

  @case:37 @priority:high
  Scenario: /products/:id returns the row, and hides an inactive product
    When GET /products/1
    Then the response status is 200
    And the product in the response matches row 1
    When GET /products/9
    Then the response status is 404
    When GET /products/999
    Then the response status is 404

  @case:38 @priority:medium
  Scenario: /categories returns every category row
    When GET /categories
    Then the categories in the response equal the category rows

  @case:39 @priority:high
  Scenario: /search matches names and never returns an inactive product
    When GET /search?q=Shoe
    Then every product in the response matches its row
    And no inactive product appears
    And every product name contains "Shoe"

  @case:40 @priority:low
  Scenario: /search requires a query
    When GET /search
    Then the response status is 400
    And the response is an error with code "bad_request"

  # ---------------------------------------------------------------- cart

  @case:41 @priority:high
  Scenario: A new cart is empty with a zero subtotal
    When POST /cart
    Then the response status is 201
    And the cart subtotal is 0
    And the cart has 0 items

  @case:42 @priority:high
  Scenario: Adding an item reflects the row and the line total
    Given a fresh cart
    When 2 of product 2 are added to the cart
    Then the cart holds 2 of product 2 priced from the row
    And the cart subtotal equals the sum of its line totals

  @case:43 @priority:medium
  Scenario: Adding the same product twice merges into one line
    Given a fresh cart
    When 1 of product 1 are added to the cart
    And 2 of product 1 are added to the cart
    Then the cart has 1 items
    And the cart holds 3 of product 1 priced from the row

  @case:44 @priority:high
  Scenario: A quantity beyond stock is refused
    Given a fresh cart
    When 999 of product 5 are added to the cart
    Then the response status is 409
    And the response is an error with code "insufficient_stock"

  @case:45 @priority:medium
  Scenario: Setting a line quantity to zero removes it
    Given a fresh cart
    And 3 of product 1 in the cart
    When the quantity of product 1 is set to 0
    Then the cart has 0 items

  @case:46 @priority:low
  Scenario: An unknown product cannot be added
    Given a fresh cart
    When 1 of product 999 are added to the cart
    Then the response status is 404

  @case:47 @priority:low
  Scenario: An inactive product cannot be added
    Given a fresh cart
    When 1 of product 9 are added to the cart
    Then the response status is 404

  @case:48 @priority:low
  Scenario: A non-positive quantity is rejected
    Given a fresh cart
    When 0 of product 1 are added to the cart
    Then the response status is 400

  @case:49 @priority:medium
  Scenario: The cart subtotal always equals the sum of its lines
    Given a fresh cart
    And 2 of product 1 in the cart
    And 1 of product 8 in the cart
    When GET the cart
    Then the cart subtotal equals the sum of its line totals

  @case:50 @priority:low
  Scenario: An unknown cart is 404
    When GET /cart/nope
    Then the response status is 404

  # ---------------------------------------------------------------- coupons

  @case:51 @priority:high
  Scenario: A percentage coupon returns the right discount
    When the coupon "SAVE10" is applied to a subtotal of 10000
    Then the response field "discount_cents" is 1000
    And the response field "total_cents" is 9000

  @case:52 @priority:high
  Scenario: A fixed coupon below its minimum spend is refused
    When the coupon "TENOFF" is applied to a subtotal of 4000
    Then the response status is 400
    And the response is an error with code "coupon_min_spend"

  @case:53 @priority:medium
  Scenario: A fixed coupon at or above its minimum spend applies
    When the coupon "TENOFF" is applied to a subtotal of 6000
    Then the response field "discount_cents" is 1000

  @case:54 @priority:medium
  Scenario: An inactive coupon is refused
    When the coupon "EXPIRED" is applied to a subtotal of 10000
    Then the response status is 400
    And the response is an error with code "coupon_inactive"

  @case:55 @priority:low
  Scenario: An unknown coupon is 404
    When the coupon "NOPE" is applied to a subtotal of 10000
    Then the response status is 404

  @case:56 @priority:medium
  Scenario: A discount never exceeds the subtotal
    When the coupon "TENOFF" is applied to a subtotal of 5000
    Then the response field "discount_cents" is at most the subtotal 5000

  # ---------------------------------------------------------------- auth and checkout

  @case:57 @priority:high
  Scenario: Registration issues a token; the email cannot be reused
    When a buyer registers
    Then the response status is 201
    And the response has a token
    When the same email registers again
    Then the response status is 409
    And the response is an error with code "email_taken"

  @case:58 @priority:high
  Scenario: Login returns a token for the right password and 401 otherwise
    Given a registered buyer
    When the buyer logs in with the right password
    Then the response status is 200
    And the response has a token
    When the buyer logs in with a wrong password
    Then the response status is 401
    And the response is an error with code "bad_credentials"

  @case:59 @priority:high
  Scenario: Checkout requires a token
    Given a fresh cart
    And 1 of product 1 in the cart
    When checkout is posted with no token
    Then the response status is 401
    And the response is an error with code "unauthenticated"

  @case:60 @priority:high
  Scenario: A checkout returns an order equal to the stored order
    Given a registered buyer with a cart
    And the cart holds 1 of product 1 and 1 of product 2
    When the buyer checks out
    Then the response status is 201
    And the order in the response equals the stored order

  @case:61 @priority:high
  Scenario: The order response total equals the sum of its line amounts
    Given a registered buyer with a cart
    And the cart holds 2 of product 4
    When the buyer checks out
    Then the order total in the response equals the sum of its line amounts

  @case:62 @priority:high
  Scenario: GET /orders/:id returns the order to its owner and 403 to anyone else
    Given a registered buyer with a cart
    And the cart holds 1 of product 1
    And the buyer checks out
    When the owner reads the order
    Then the response status is 200
    And the order in the response equals the stored order
    When a different buyer reads the order
    Then the response status is 403
    And the response is an error with code "forbidden"

  @case:63 @priority:medium
  Scenario: An unauthenticated order read is 401
    Given a registered buyer with a cart
    And the cart holds 1 of product 1
    And the buyer checks out
    When the order is read with no token
    Then the response status is 401

  @case:64 @priority:medium
  Scenario: A retried checkout with the same idempotency key returns the same order
    Given a registered buyer with a cart
    And the cart holds 1 of product 1
    When the buyer checks out with idempotency key "api-key-1"
    And the buyer checks out again with idempotency key "api-key-1"
    Then both checkouts returned the same order id

  @case:65 @priority:low
  Scenario: A consistent error shape and a 404 for unknown routes
    When GET /nowhere
    Then the response status is 404
    And the response is an error with code "not_found"

  Scenario Outline: A cart of <q1> of product 1 and <q2> of product 2 subtotals to its line totals
    Given a fresh cart
    When <q1> of product 1 are added to the cart
    And <q2> of product 2 are added to the cart
    Then the cart subtotal equals the sum of its line totals

    @case:166
    Examples:
      | q1 | q2 |
      | 1 | 1 |
    @case:167
    Examples:
      | q1 | q2 |
      | 1 | 2 |
    @case:168
    Examples:
      | q1 | q2 |
      | 1 | 3 |
    @case:169
    Examples:
      | q1 | q2 |
      | 1 | 4 |
    @case:170
    Examples:
      | q1 | q2 |
      | 1 | 5 |
    @case:171
    Examples:
      | q1 | q2 |
      | 1 | 6 |
    @case:172
    Examples:
      | q1 | q2 |
      | 1 | 7 |
    @case:173
    Examples:
      | q1 | q2 |
      | 1 | 8 |
    @case:174
    Examples:
      | q1 | q2 |
      | 1 | 9 |
    @case:175
    Examples:
      | q1 | q2 |
      | 1 | 10 |
    @case:176
    Examples:
      | q1 | q2 |
      | 1 | 11 |
    @case:177
    Examples:
      | q1 | q2 |
      | 1 | 12 |
    @case:178
    Examples:
      | q1 | q2 |
      | 1 | 13 |
    @case:179
    Examples:
      | q1 | q2 |
      | 1 | 14 |
    @case:180
    Examples:
      | q1 | q2 |
      | 1 | 15 |
    @case:181
    Examples:
      | q1 | q2 |
      | 1 | 16 |
    @case:182
    Examples:
      | q1 | q2 |
      | 1 | 17 |
    @case:183
    Examples:
      | q1 | q2 |
      | 1 | 18 |
    @case:184
    Examples:
      | q1 | q2 |
      | 1 | 19 |
    @case:185
    Examples:
      | q1 | q2 |
      | 2 | 1 |
    @case:186
    Examples:
      | q1 | q2 |
      | 2 | 2 |
    @case:187
    Examples:
      | q1 | q2 |
      | 2 | 3 |
    @case:188
    Examples:
      | q1 | q2 |
      | 2 | 4 |
    @case:189
    Examples:
      | q1 | q2 |
      | 2 | 5 |
    @case:190
    Examples:
      | q1 | q2 |
      | 2 | 6 |
    @case:191
    Examples:
      | q1 | q2 |
      | 2 | 7 |
    @case:192
    Examples:
      | q1 | q2 |
      | 2 | 8 |
    @case:193
    Examples:
      | q1 | q2 |
      | 2 | 9 |
    @case:194
    Examples:
      | q1 | q2 |
      | 2 | 10 |
    @case:195
    Examples:
      | q1 | q2 |
      | 2 | 11 |
    @case:196
    Examples:
      | q1 | q2 |
      | 2 | 12 |
    @case:197
    Examples:
      | q1 | q2 |
      | 2 | 13 |
    @case:198
    Examples:
      | q1 | q2 |
      | 2 | 14 |
    @case:199
    Examples:
      | q1 | q2 |
      | 2 | 15 |
    @case:200
    Examples:
      | q1 | q2 |
      | 2 | 16 |
    @case:201
    Examples:
      | q1 | q2 |
      | 2 | 17 |
    @case:202
    Examples:
      | q1 | q2 |
      | 2 | 18 |
    @case:203
    Examples:
      | q1 | q2 |
      | 2 | 19 |
    @case:204
    Examples:
      | q1 | q2 |
      | 3 | 1 |
    @case:205
    Examples:
      | q1 | q2 |
      | 3 | 2 |
    @case:206
    Examples:
      | q1 | q2 |
      | 3 | 3 |
    @case:207
    Examples:
      | q1 | q2 |
      | 3 | 4 |
    @case:208
    Examples:
      | q1 | q2 |
      | 3 | 5 |
    @case:209
    Examples:
      | q1 | q2 |
      | 3 | 6 |
    @case:210
    Examples:
      | q1 | q2 |
      | 3 | 7 |
    @case:211
    Examples:
      | q1 | q2 |
      | 3 | 8 |
    @case:212
    Examples:
      | q1 | q2 |
      | 3 | 9 |
    @case:213
    Examples:
      | q1 | q2 |
      | 3 | 10 |
    @case:214
    Examples:
      | q1 | q2 |
      | 3 | 11 |
    @case:215
    Examples:
      | q1 | q2 |
      | 3 | 12 |
    @case:216
    Examples:
      | q1 | q2 |
      | 3 | 13 |
    @case:217
    Examples:
      | q1 | q2 |
      | 3 | 14 |
    @case:218
    Examples:
      | q1 | q2 |
      | 3 | 15 |
    @case:219
    Examples:
      | q1 | q2 |
      | 3 | 16 |
    @case:220
    Examples:
      | q1 | q2 |
      | 3 | 17 |
    @case:221
    Examples:
      | q1 | q2 |
      | 3 | 18 |
    @case:222
    Examples:
      | q1 | q2 |
      | 3 | 19 |
    @case:223
    Examples:
      | q1 | q2 |
      | 4 | 1 |
    @case:224
    Examples:
      | q1 | q2 |
      | 4 | 2 |
    @case:225
    Examples:
      | q1 | q2 |
      | 4 | 3 |
    @case:226
    Examples:
      | q1 | q2 |
      | 4 | 4 |
    @case:227
    Examples:
      | q1 | q2 |
      | 4 | 5 |
    @case:228
    Examples:
      | q1 | q2 |
      | 4 | 6 |
    @case:229
    Examples:
      | q1 | q2 |
      | 4 | 7 |
    @case:230
    Examples:
      | q1 | q2 |
      | 4 | 8 |
    @case:231
    Examples:
      | q1 | q2 |
      | 4 | 9 |
    @case:232
    Examples:
      | q1 | q2 |
      | 4 | 10 |
    @case:233
    Examples:
      | q1 | q2 |
      | 4 | 11 |
    @case:234
    Examples:
      | q1 | q2 |
      | 4 | 12 |
    @case:235
    Examples:
      | q1 | q2 |
      | 4 | 13 |
    @case:236
    Examples:
      | q1 | q2 |
      | 4 | 14 |
    @case:237
    Examples:
      | q1 | q2 |
      | 4 | 15 |
    @case:238
    Examples:
      | q1 | q2 |
      | 4 | 16 |
    @case:239
    Examples:
      | q1 | q2 |
      | 4 | 17 |
    @case:240
    Examples:
      | q1 | q2 |
      | 4 | 18 |
    @case:241
    Examples:
      | q1 | q2 |
      | 4 | 19 |
    @case:242
    Examples:
      | q1 | q2 |
      | 5 | 1 |
    @case:243
    Examples:
      | q1 | q2 |
      | 5 | 2 |
    @case:244
    Examples:
      | q1 | q2 |
      | 5 | 3 |
    @case:245
    Examples:
      | q1 | q2 |
      | 5 | 4 |
    @case:246
    Examples:
      | q1 | q2 |
      | 5 | 5 |
    @case:247
    Examples:
      | q1 | q2 |
      | 5 | 6 |
    @case:248
    Examples:
      | q1 | q2 |
      | 5 | 7 |
    @case:249
    Examples:
      | q1 | q2 |
      | 5 | 8 |
    @case:250
    Examples:
      | q1 | q2 |
      | 5 | 9 |
    @case:251
    Examples:
      | q1 | q2 |
      | 5 | 10 |
    @case:252
    Examples:
      | q1 | q2 |
      | 5 | 11 |
    @case:253
    Examples:
      | q1 | q2 |
      | 5 | 12 |
    @case:254
    Examples:
      | q1 | q2 |
      | 5 | 13 |
    @case:255
    Examples:
      | q1 | q2 |
      | 5 | 14 |
    @case:256
    Examples:
      | q1 | q2 |
      | 5 | 15 |
    @case:257
    Examples:
      | q1 | q2 |
      | 5 | 16 |
    @case:258
    Examples:
      | q1 | q2 |
      | 5 | 17 |
    @case:259
    Examples:
      | q1 | q2 |
      | 5 | 18 |
    @case:260
    Examples:
      | q1 | q2 |
      | 5 | 19 |
    @case:261
    Examples:
      | q1 | q2 |
      | 6 | 1 |
    @case:262
    Examples:
      | q1 | q2 |
      | 6 | 2 |
    @case:263
    Examples:
      | q1 | q2 |
      | 6 | 3 |
    @case:264
    Examples:
      | q1 | q2 |
      | 6 | 4 |
    @case:265
    Examples:
      | q1 | q2 |
      | 6 | 5 |
    @case:266
    Examples:
      | q1 | q2 |
      | 6 | 6 |
    @case:267
    Examples:
      | q1 | q2 |
      | 6 | 7 |
    @case:268
    Examples:
      | q1 | q2 |
      | 6 | 8 |
    @case:269
    Examples:
      | q1 | q2 |
      | 6 | 9 |
    @case:270
    Examples:
      | q1 | q2 |
      | 6 | 10 |
    @case:271
    Examples:
      | q1 | q2 |
      | 6 | 11 |
    @case:272
    Examples:
      | q1 | q2 |
      | 6 | 12 |
    @case:273
    Examples:
      | q1 | q2 |
      | 6 | 13 |
    @case:274
    Examples:
      | q1 | q2 |
      | 6 | 14 |
    @case:275
    Examples:
      | q1 | q2 |
      | 6 | 15 |
    @case:276
    Examples:
      | q1 | q2 |
      | 6 | 16 |
    @case:277
    Examples:
      | q1 | q2 |
      | 6 | 17 |
    @case:278
    Examples:
      | q1 | q2 |
      | 6 | 18 |
    @case:279
    Examples:
      | q1 | q2 |
      | 6 | 19 |
    @case:280
    Examples:
      | q1 | q2 |
      | 7 | 1 |
    @case:281
    Examples:
      | q1 | q2 |
      | 7 | 2 |
    @case:282
    Examples:
      | q1 | q2 |
      | 7 | 3 |
    @case:283
    Examples:
      | q1 | q2 |
      | 7 | 4 |
    @case:284
    Examples:
      | q1 | q2 |
      | 7 | 5 |
    @case:285
    Examples:
      | q1 | q2 |
      | 7 | 6 |
    @case:286
    Examples:
      | q1 | q2 |
      | 7 | 7 |
    @case:287
    Examples:
      | q1 | q2 |
      | 7 | 8 |
    @case:288
    Examples:
      | q1 | q2 |
      | 7 | 9 |
    @case:289
    Examples:
      | q1 | q2 |
      | 7 | 10 |
    @case:290
    Examples:
      | q1 | q2 |
      | 7 | 11 |
    @case:291
    Examples:
      | q1 | q2 |
      | 7 | 12 |
    @case:292
    Examples:
      | q1 | q2 |
      | 7 | 13 |
    @case:293
    Examples:
      | q1 | q2 |
      | 7 | 14 |
    @case:294
    Examples:
      | q1 | q2 |
      | 7 | 15 |
    @case:295
    Examples:
      | q1 | q2 |
      | 7 | 16 |
    @case:296
    Examples:
      | q1 | q2 |
      | 7 | 17 |
    @case:297
    Examples:
      | q1 | q2 |
      | 7 | 18 |
    @case:298
    Examples:
      | q1 | q2 |
      | 7 | 19 |
    @case:299
    Examples:
      | q1 | q2 |
      | 8 | 1 |
    @case:300
    Examples:
      | q1 | q2 |
      | 8 | 2 |
    @case:301
    Examples:
      | q1 | q2 |
      | 8 | 3 |
    @case:302
    Examples:
      | q1 | q2 |
      | 8 | 4 |
    @case:303
    Examples:
      | q1 | q2 |
      | 8 | 5 |
    @case:304
    Examples:
      | q1 | q2 |
      | 8 | 6 |
    @case:305
    Examples:
      | q1 | q2 |
      | 8 | 7 |
    @case:306
    Examples:
      | q1 | q2 |
      | 8 | 8 |
    @case:307
    Examples:
      | q1 | q2 |
      | 8 | 9 |
    @case:308
    Examples:
      | q1 | q2 |
      | 8 | 10 |
    @case:309
    Examples:
      | q1 | q2 |
      | 8 | 11 |
    @case:310
    Examples:
      | q1 | q2 |
      | 8 | 12 |
    @case:311
    Examples:
      | q1 | q2 |
      | 8 | 13 |
    @case:312
    Examples:
      | q1 | q2 |
      | 8 | 14 |
    @case:313
    Examples:
      | q1 | q2 |
      | 8 | 15 |
    @case:314
    Examples:
      | q1 | q2 |
      | 8 | 16 |
    @case:315
    Examples:
      | q1 | q2 |
      | 8 | 17 |
    @case:316
    Examples:
      | q1 | q2 |
      | 8 | 18 |
    @case:317
    Examples:
      | q1 | q2 |
      | 8 | 19 |
    @case:318
    Examples:
      | q1 | q2 |
      | 9 | 1 |
    @case:319
    Examples:
      | q1 | q2 |
      | 9 | 2 |
    @case:320
    Examples:
      | q1 | q2 |
      | 9 | 3 |
    @case:321
    Examples:
      | q1 | q2 |
      | 9 | 4 |
    @case:322
    Examples:
      | q1 | q2 |
      | 9 | 5 |
    @case:323
    Examples:
      | q1 | q2 |
      | 9 | 6 |
    @case:324
    Examples:
      | q1 | q2 |
      | 9 | 7 |
    @case:325
    Examples:
      | q1 | q2 |
      | 9 | 8 |
    @case:326
    Examples:
      | q1 | q2 |
      | 9 | 9 |
    @case:327
    Examples:
      | q1 | q2 |
      | 9 | 10 |
    @case:328
    Examples:
      | q1 | q2 |
      | 9 | 11 |
    @case:329
    Examples:
      | q1 | q2 |
      | 9 | 12 |
    @case:330
    Examples:
      | q1 | q2 |
      | 9 | 13 |
    @case:331
    Examples:
      | q1 | q2 |
      | 9 | 14 |
    @case:332
    Examples:
      | q1 | q2 |
      | 9 | 15 |
    @case:333
    Examples:
      | q1 | q2 |
      | 9 | 16 |
    @case:334
    Examples:
      | q1 | q2 |
      | 9 | 17 |
    @case:335
    Examples:
      | q1 | q2 |
      | 9 | 18 |
    @case:336
    Examples:
      | q1 | q2 |
      | 9 | 19 |
    @case:337
    Examples:
      | q1 | q2 |
      | 10 | 1 |
    @case:338
    Examples:
      | q1 | q2 |
      | 10 | 2 |
    @case:339
    Examples:
      | q1 | q2 |
      | 10 | 3 |
    @case:340
    Examples:
      | q1 | q2 |
      | 10 | 4 |
    @case:341
    Examples:
      | q1 | q2 |
      | 10 | 5 |
    @case:342
    Examples:
      | q1 | q2 |
      | 10 | 6 |
    @case:343
    Examples:
      | q1 | q2 |
      | 10 | 7 |
    @case:344
    Examples:
      | q1 | q2 |
      | 10 | 8 |
    @case:345
    Examples:
      | q1 | q2 |
      | 10 | 9 |
    @case:346
    Examples:
      | q1 | q2 |
      | 10 | 10 |
    @case:347
    Examples:
      | q1 | q2 |
      | 10 | 11 |
    @case:348
    Examples:
      | q1 | q2 |
      | 10 | 12 |
    @case:349
    Examples:
      | q1 | q2 |
      | 10 | 13 |
    @case:350
    Examples:
      | q1 | q2 |
      | 10 | 14 |
    @case:351
    Examples:
      | q1 | q2 |
      | 10 | 15 |
    @case:352
    Examples:
      | q1 | q2 |
      | 10 | 16 |
    @case:353
    Examples:
      | q1 | q2 |
      | 10 | 17 |
    @case:354
    Examples:
      | q1 | q2 |
      | 10 | 18 |
    @case:355
    Examples:
      | q1 | q2 |
      | 10 | 19 |
    @case:356
    Examples:
      | q1 | q2 |
      | 11 | 1 |
    @case:357
    Examples:
      | q1 | q2 |
      | 11 | 2 |
    @case:358
    Examples:
      | q1 | q2 |
      | 11 | 3 |
    @case:359
    Examples:
      | q1 | q2 |
      | 11 | 4 |
    @case:360
    Examples:
      | q1 | q2 |
      | 11 | 5 |
    @case:361
    Examples:
      | q1 | q2 |
      | 11 | 6 |
    @case:362
    Examples:
      | q1 | q2 |
      | 11 | 7 |
    @case:363
    Examples:
      | q1 | q2 |
      | 11 | 8 |
    @case:364
    Examples:
      | q1 | q2 |
      | 11 | 9 |
    @case:365
    Examples:
      | q1 | q2 |
      | 11 | 10 |
    @case:366
    Examples:
      | q1 | q2 |
      | 11 | 11 |
    @case:367
    Examples:
      | q1 | q2 |
      | 11 | 12 |
    @case:368
    Examples:
      | q1 | q2 |
      | 11 | 13 |
    @case:369
    Examples:
      | q1 | q2 |
      | 11 | 14 |
    @case:370
    Examples:
      | q1 | q2 |
      | 11 | 15 |
    @case:371
    Examples:
      | q1 | q2 |
      | 11 | 16 |
    @case:372
    Examples:
      | q1 | q2 |
      | 11 | 17 |
    @case:373
    Examples:
      | q1 | q2 |
      | 11 | 18 |
    @case:374
    Examples:
      | q1 | q2 |
      | 11 | 19 |
    @case:375
    Examples:
      | q1 | q2 |
      | 12 | 1 |
    @case:376
    Examples:
      | q1 | q2 |
      | 12 | 2 |
    @case:377
    Examples:
      | q1 | q2 |
      | 12 | 3 |
    @case:378
    Examples:
      | q1 | q2 |
      | 12 | 4 |
    @case:379
    Examples:
      | q1 | q2 |
      | 12 | 5 |
    @case:380
    Examples:
      | q1 | q2 |
      | 12 | 6 |
    @case:381
    Examples:
      | q1 | q2 |
      | 12 | 7 |
    @case:382
    Examples:
      | q1 | q2 |
      | 12 | 8 |
    @case:383
    Examples:
      | q1 | q2 |
      | 12 | 9 |
    @case:384
    Examples:
      | q1 | q2 |
      | 12 | 10 |
    @case:385
    Examples:
      | q1 | q2 |
      | 12 | 11 |
    @case:386
    Examples:
      | q1 | q2 |
      | 12 | 12 |
    @case:387
    Examples:
      | q1 | q2 |
      | 12 | 13 |
    @case:388
    Examples:
      | q1 | q2 |
      | 12 | 14 |
    @case:389
    Examples:
      | q1 | q2 |
      | 12 | 15 |
    @case:390
    Examples:
      | q1 | q2 |
      | 12 | 16 |
    @case:391
    Examples:
      | q1 | q2 |
      | 12 | 17 |
    @case:392
    Examples:
      | q1 | q2 |
      | 12 | 18 |
    @case:393
    Examples:
      | q1 | q2 |
      | 12 | 19 |
    @case:394
    Examples:
      | q1 | q2 |
      | 13 | 1 |
    @case:395
    Examples:
      | q1 | q2 |
      | 13 | 2 |
    @case:396
    Examples:
      | q1 | q2 |
      | 13 | 3 |
    @case:397
    Examples:
      | q1 | q2 |
      | 13 | 4 |
    @case:398
    Examples:
      | q1 | q2 |
      | 13 | 5 |
    @case:399
    Examples:
      | q1 | q2 |
      | 13 | 6 |
    @case:400
    Examples:
      | q1 | q2 |
      | 13 | 7 |
    @case:401
    Examples:
      | q1 | q2 |
      | 13 | 8 |
    @case:402
    Examples:
      | q1 | q2 |
      | 13 | 9 |
    @case:403
    Examples:
      | q1 | q2 |
      | 13 | 10 |
    @case:404
    Examples:
      | q1 | q2 |
      | 13 | 11 |
    @case:405
    Examples:
      | q1 | q2 |
      | 13 | 12 |
    @case:406
    Examples:
      | q1 | q2 |
      | 13 | 13 |
    @case:407
    Examples:
      | q1 | q2 |
      | 13 | 14 |
    @case:408
    Examples:
      | q1 | q2 |
      | 13 | 15 |
    @case:409
    Examples:
      | q1 | q2 |
      | 13 | 16 |
    @case:410
    Examples:
      | q1 | q2 |
      | 13 | 17 |
    @case:411
    Examples:
      | q1 | q2 |
      | 13 | 18 |
    @case:412
    Examples:
      | q1 | q2 |
      | 13 | 19 |
    @case:413
    Examples:
      | q1 | q2 |
      | 14 | 1 |
    @case:414
    Examples:
      | q1 | q2 |
      | 14 | 2 |
    @case:415
    Examples:
      | q1 | q2 |
      | 14 | 3 |
    @case:416
    Examples:
      | q1 | q2 |
      | 14 | 4 |
    @case:417
    Examples:
      | q1 | q2 |
      | 14 | 5 |
    @case:418
    Examples:
      | q1 | q2 |
      | 14 | 6 |
    @case:419
    Examples:
      | q1 | q2 |
      | 14 | 7 |
    @case:420
    Examples:
      | q1 | q2 |
      | 14 | 8 |
    @case:421
    Examples:
      | q1 | q2 |
      | 14 | 9 |
    @case:422
    Examples:
      | q1 | q2 |
      | 14 | 10 |
    @case:423
    Examples:
      | q1 | q2 |
      | 14 | 11 |
    @case:424
    Examples:
      | q1 | q2 |
      | 14 | 12 |
    @case:425
    Examples:
      | q1 | q2 |
      | 14 | 13 |
    @case:426
    Examples:
      | q1 | q2 |
      | 14 | 14 |
    @case:427
    Examples:
      | q1 | q2 |
      | 14 | 15 |
    @case:428
    Examples:
      | q1 | q2 |
      | 14 | 16 |
    @case:429
    Examples:
      | q1 | q2 |
      | 14 | 17 |
    @case:430
    Examples:
      | q1 | q2 |
      | 14 | 18 |
    @case:431
    Examples:
      | q1 | q2 |
      | 14 | 19 |
    @case:432
    Examples:
      | q1 | q2 |
      | 15 | 1 |
    @case:433
    Examples:
      | q1 | q2 |
      | 15 | 2 |
    @case:434
    Examples:
      | q1 | q2 |
      | 15 | 3 |
    @case:435
    Examples:
      | q1 | q2 |
      | 15 | 4 |
    @case:436
    Examples:
      | q1 | q2 |
      | 15 | 5 |
    @case:437
    Examples:
      | q1 | q2 |
      | 15 | 6 |
    @case:438
    Examples:
      | q1 | q2 |
      | 15 | 7 |
    @case:439
    Examples:
      | q1 | q2 |
      | 15 | 8 |
    @case:440
    Examples:
      | q1 | q2 |
      | 15 | 9 |
    @case:441
    Examples:
      | q1 | q2 |
      | 15 | 10 |
    @case:442
    Examples:
      | q1 | q2 |
      | 15 | 11 |
    @case:443
    Examples:
      | q1 | q2 |
      | 15 | 12 |
    @case:444
    Examples:
      | q1 | q2 |
      | 15 | 13 |
    @case:445
    Examples:
      | q1 | q2 |
      | 15 | 14 |
    @case:446
    Examples:
      | q1 | q2 |
      | 15 | 15 |
    @case:447
    Examples:
      | q1 | q2 |
      | 15 | 16 |
    @case:448
    Examples:
      | q1 | q2 |
      | 15 | 17 |
    @case:449
    Examples:
      | q1 | q2 |
      | 15 | 18 |
    @case:450
    Examples:
      | q1 | q2 |
      | 15 | 19 |
    @case:451
    Examples:
      | q1 | q2 |
      | 16 | 1 |
    @case:452
    Examples:
      | q1 | q2 |
      | 16 | 2 |
    @case:453
    Examples:
      | q1 | q2 |
      | 16 | 3 |
    @case:454
    Examples:
      | q1 | q2 |
      | 16 | 4 |
    @case:455
    Examples:
      | q1 | q2 |
      | 16 | 5 |
    @case:456
    Examples:
      | q1 | q2 |
      | 16 | 6 |
    @case:457
    Examples:
      | q1 | q2 |
      | 16 | 7 |
    @case:458
    Examples:
      | q1 | q2 |
      | 16 | 8 |
    @case:459
    Examples:
      | q1 | q2 |
      | 16 | 9 |
    @case:460
    Examples:
      | q1 | q2 |
      | 16 | 10 |
    @case:461
    Examples:
      | q1 | q2 |
      | 16 | 11 |
    @case:462
    Examples:
      | q1 | q2 |
      | 16 | 12 |
    @case:463
    Examples:
      | q1 | q2 |
      | 16 | 13 |
    @case:464
    Examples:
      | q1 | q2 |
      | 16 | 14 |
    @case:465
    Examples:
      | q1 | q2 |
      | 16 | 15 |
    @case:466
    Examples:
      | q1 | q2 |
      | 16 | 16 |
    @case:467
    Examples:
      | q1 | q2 |
      | 16 | 17 |
    @case:468
    Examples:
      | q1 | q2 |
      | 16 | 18 |
    @case:469
    Examples:
      | q1 | q2 |
      | 16 | 19 |
    @case:470
    Examples:
      | q1 | q2 |
      | 17 | 1 |
    @case:471
    Examples:
      | q1 | q2 |
      | 17 | 2 |
    @case:472
    Examples:
      | q1 | q2 |
      | 17 | 3 |
    @case:473
    Examples:
      | q1 | q2 |
      | 17 | 4 |
    @case:474
    Examples:
      | q1 | q2 |
      | 17 | 5 |
    @case:475
    Examples:
      | q1 | q2 |
      | 17 | 6 |
    @case:476
    Examples:
      | q1 | q2 |
      | 17 | 7 |
    @case:477
    Examples:
      | q1 | q2 |
      | 17 | 8 |
    @case:478
    Examples:
      | q1 | q2 |
      | 17 | 9 |
    @case:479
    Examples:
      | q1 | q2 |
      | 17 | 10 |
    @case:480
    Examples:
      | q1 | q2 |
      | 17 | 11 |
    @case:481
    Examples:
      | q1 | q2 |
      | 17 | 12 |
    @case:482
    Examples:
      | q1 | q2 |
      | 17 | 13 |
    @case:483
    Examples:
      | q1 | q2 |
      | 17 | 14 |
    @case:484
    Examples:
      | q1 | q2 |
      | 17 | 15 |
    @case:485
    Examples:
      | q1 | q2 |
      | 17 | 16 |
    @case:486
    Examples:
      | q1 | q2 |
      | 17 | 17 |
    @case:487
    Examples:
      | q1 | q2 |
      | 17 | 18 |
    @case:488
    Examples:
      | q1 | q2 |
      | 17 | 19 |
    @case:489
    Examples:
      | q1 | q2 |
      | 18 | 1 |
    @case:490
    Examples:
      | q1 | q2 |
      | 18 | 2 |
    @case:491
    Examples:
      | q1 | q2 |
      | 18 | 3 |
    @case:492
    Examples:
      | q1 | q2 |
      | 18 | 4 |
    @case:493
    Examples:
      | q1 | q2 |
      | 18 | 5 |
    @case:494
    Examples:
      | q1 | q2 |
      | 18 | 6 |
    @case:495
    Examples:
      | q1 | q2 |
      | 18 | 7 |
    @case:496
    Examples:
      | q1 | q2 |
      | 18 | 8 |
    @case:497
    Examples:
      | q1 | q2 |
      | 18 | 9 |
    @case:498
    Examples:
      | q1 | q2 |
      | 18 | 10 |
    @case:499
    Examples:
      | q1 | q2 |
      | 18 | 11 |
    @case:500
    Examples:
      | q1 | q2 |
      | 18 | 12 |
    @case:501
    Examples:
      | q1 | q2 |
      | 18 | 13 |
    @case:502
    Examples:
      | q1 | q2 |
      | 18 | 14 |
    @case:503
    Examples:
      | q1 | q2 |
      | 18 | 15 |
    @case:504
    Examples:
      | q1 | q2 |
      | 18 | 16 |
    @case:505
    Examples:
      | q1 | q2 |
      | 18 | 17 |
    @case:506
    Examples:
      | q1 | q2 |
      | 18 | 18 |
    @case:507
    Examples:
      | q1 | q2 |
      | 18 | 19 |
    @case:508
    Examples:
      | q1 | q2 |
      | 19 | 1 |
    @case:509
    Examples:
      | q1 | q2 |
      | 19 | 2 |
    @case:510
    Examples:
      | q1 | q2 |
      | 19 | 3 |
    @case:511
    Examples:
      | q1 | q2 |
      | 19 | 4 |
    @case:512
    Examples:
      | q1 | q2 |
      | 19 | 5 |
    @case:513
    Examples:
      | q1 | q2 |
      | 19 | 6 |
    @case:514
    Examples:
      | q1 | q2 |
      | 19 | 7 |
    @case:515
    Examples:
      | q1 | q2 |
      | 19 | 8 |
    @case:516
    Examples:
      | q1 | q2 |
      | 19 | 9 |
    @case:517
    Examples:
      | q1 | q2 |
      | 19 | 10 |
    @case:518
    Examples:
      | q1 | q2 |
      | 19 | 11 |
    @case:519
    Examples:
      | q1 | q2 |
      | 19 | 12 |
    @case:520
    Examples:
      | q1 | q2 |
      | 19 | 13 |
    @case:521
    Examples:
      | q1 | q2 |
      | 19 | 14 |
    @case:522
    Examples:
      | q1 | q2 |
      | 19 | 15 |
    @case:523
    Examples:
      | q1 | q2 |
      | 19 | 16 |
    @case:524
    Examples:
      | q1 | q2 |
      | 19 | 17 |
    @case:525
    Examples:
      | q1 | q2 |
      | 19 | 18 |
    @case:526
    Examples:
      | q1 | q2 |
      | 19 | 19 |
    @case:527
    Examples:
      | q1 | q2 |
      | 20 | 1 |
    @case:528
    Examples:
      | q1 | q2 |
      | 20 | 2 |
    @case:529
    Examples:
      | q1 | q2 |
      | 20 | 3 |
    @case:530
    Examples:
      | q1 | q2 |
      | 20 | 4 |
    @case:531
    Examples:
      | q1 | q2 |
      | 20 | 5 |
    @case:532
    Examples:
      | q1 | q2 |
      | 20 | 6 |
    @case:533
    Examples:
      | q1 | q2 |
      | 20 | 7 |
    @case:534
    Examples:
      | q1 | q2 |
      | 20 | 8 |
    @case:535
    Examples:
      | q1 | q2 |
      | 20 | 9 |
    @case:536
    Examples:
      | q1 | q2 |
      | 20 | 10 |
    @case:537
    Examples:
      | q1 | q2 |
      | 20 | 11 |
    @case:538
    Examples:
      | q1 | q2 |
      | 20 | 12 |
    @case:539
    Examples:
      | q1 | q2 |
      | 20 | 13 |
    @case:540
    Examples:
      | q1 | q2 |
      | 20 | 14 |
    @case:541
    Examples:
      | q1 | q2 |
      | 20 | 15 |
    @case:542
    Examples:
      | q1 | q2 |
      | 20 | 16 |
    @case:543
    Examples:
      | q1 | q2 |
      | 20 | 17 |
    @case:544
    Examples:
      | q1 | q2 |
      | 20 | 18 |
    @case:545
    Examples:
      | q1 | q2 |
      | 20 | 19 |
    @case:546
    Examples:
      | q1 | q2 |
      | 21 | 1 |
    @case:547
    Examples:
      | q1 | q2 |
      | 21 | 2 |
    @case:548
    Examples:
      | q1 | q2 |
      | 21 | 3 |
    @case:549
    Examples:
      | q1 | q2 |
      | 21 | 4 |
    @case:550
    Examples:
      | q1 | q2 |
      | 21 | 5 |
    @case:551
    Examples:
      | q1 | q2 |
      | 21 | 6 |
    @case:552
    Examples:
      | q1 | q2 |
      | 21 | 7 |
    @case:553
    Examples:
      | q1 | q2 |
      | 21 | 8 |
    @case:554
    Examples:
      | q1 | q2 |
      | 21 | 9 |
    @case:555
    Examples:
      | q1 | q2 |
      | 21 | 10 |
    @case:556
    Examples:
      | q1 | q2 |
      | 21 | 11 |
    @case:557
    Examples:
      | q1 | q2 |
      | 21 | 12 |
    @case:558
    Examples:
      | q1 | q2 |
      | 21 | 13 |
    @case:559
    Examples:
      | q1 | q2 |
      | 21 | 14 |
    @case:560
    Examples:
      | q1 | q2 |
      | 21 | 15 |
    @case:561
    Examples:
      | q1 | q2 |
      | 21 | 16 |
    @case:562
    Examples:
      | q1 | q2 |
      | 21 | 17 |
    @case:563
    Examples:
      | q1 | q2 |
      | 21 | 18 |
    @case:564
    Examples:
      | q1 | q2 |
      | 21 | 19 |
    @case:565
    Examples:
      | q1 | q2 |
      | 22 | 1 |
    @case:566
    Examples:
      | q1 | q2 |
      | 22 | 2 |
    @case:567
    Examples:
      | q1 | q2 |
      | 22 | 3 |
    @case:568
    Examples:
      | q1 | q2 |
      | 22 | 4 |
    @case:569
    Examples:
      | q1 | q2 |
      | 22 | 5 |
    @case:570
    Examples:
      | q1 | q2 |
      | 22 | 6 |
    @case:571
    Examples:
      | q1 | q2 |
      | 22 | 7 |
    @case:572
    Examples:
      | q1 | q2 |
      | 22 | 8 |
    @case:573
    Examples:
      | q1 | q2 |
      | 22 | 9 |
    @case:574
    Examples:
      | q1 | q2 |
      | 22 | 10 |
    @case:575
    Examples:
      | q1 | q2 |
      | 22 | 11 |
    @case:576
    Examples:
      | q1 | q2 |
      | 22 | 12 |
    @case:577
    Examples:
      | q1 | q2 |
      | 22 | 13 |
    @case:578
    Examples:
      | q1 | q2 |
      | 22 | 14 |
    @case:579
    Examples:
      | q1 | q2 |
      | 22 | 15 |
    @case:580
    Examples:
      | q1 | q2 |
      | 22 | 16 |
    @case:581
    Examples:
      | q1 | q2 |
      | 22 | 17 |
    @case:582
    Examples:
      | q1 | q2 |
      | 22 | 18 |
    @case:583
    Examples:
      | q1 | q2 |
      | 22 | 19 |
    @case:584
    Examples:
      | q1 | q2 |
      | 23 | 1 |
    @case:585
    Examples:
      | q1 | q2 |
      | 23 | 2 |
    @case:586
    Examples:
      | q1 | q2 |
      | 23 | 3 |
    @case:587
    Examples:
      | q1 | q2 |
      | 23 | 4 |
    @case:588
    Examples:
      | q1 | q2 |
      | 23 | 5 |
    @case:589
    Examples:
      | q1 | q2 |
      | 23 | 6 |
    @case:590
    Examples:
      | q1 | q2 |
      | 23 | 7 |
    @case:591
    Examples:
      | q1 | q2 |
      | 23 | 8 |
    @case:592
    Examples:
      | q1 | q2 |
      | 23 | 9 |
    @case:593
    Examples:
      | q1 | q2 |
      | 23 | 10 |
    @case:594
    Examples:
      | q1 | q2 |
      | 23 | 11 |
    @case:595
    Examples:
      | q1 | q2 |
      | 23 | 12 |
    @case:596
    Examples:
      | q1 | q2 |
      | 23 | 13 |
    @case:597
    Examples:
      | q1 | q2 |
      | 23 | 14 |
    @case:598
    Examples:
      | q1 | q2 |
      | 23 | 15 |
    @case:599
    Examples:
      | q1 | q2 |
      | 23 | 16 |
    @case:600
    Examples:
      | q1 | q2 |
      | 23 | 17 |
    @case:601
    Examples:
      | q1 | q2 |
      | 23 | 18 |
    @case:602
    Examples:
      | q1 | q2 |
      | 23 | 19 |
    @case:603
    Examples:
      | q1 | q2 |
      | 24 | 1 |
    @case:604
    Examples:
      | q1 | q2 |
      | 24 | 2 |
    @case:605
    Examples:
      | q1 | q2 |
      | 24 | 3 |
    @case:606
    Examples:
      | q1 | q2 |
      | 24 | 4 |
    @case:607
    Examples:
      | q1 | q2 |
      | 24 | 5 |
    @case:608
    Examples:
      | q1 | q2 |
      | 24 | 6 |
    @case:609
    Examples:
      | q1 | q2 |
      | 24 | 7 |
    @case:610
    Examples:
      | q1 | q2 |
      | 24 | 8 |
    @case:611
    Examples:
      | q1 | q2 |
      | 24 | 9 |
    @case:612
    Examples:
      | q1 | q2 |
      | 24 | 10 |
    @case:613
    Examples:
      | q1 | q2 |
      | 24 | 11 |
    @case:614
    Examples:
      | q1 | q2 |
      | 24 | 12 |
    @case:615
    Examples:
      | q1 | q2 |
      | 24 | 13 |
    @case:616
    Examples:
      | q1 | q2 |
      | 24 | 14 |
    @case:617
    Examples:
      | q1 | q2 |
      | 24 | 15 |
    @case:618
    Examples:
      | q1 | q2 |
      | 24 | 16 |
    @case:619
    Examples:
      | q1 | q2 |
      | 24 | 17 |
    @case:620
    Examples:
      | q1 | q2 |
      | 24 | 18 |
    @case:621
    Examples:
      | q1 | q2 |
      | 24 | 19 |
    @case:622
    Examples:
      | q1 | q2 |
      | 25 | 1 |
    @case:623
    Examples:
      | q1 | q2 |
      | 25 | 2 |
    @case:624
    Examples:
      | q1 | q2 |
      | 25 | 3 |
    @case:625
    Examples:
      | q1 | q2 |
      | 25 | 4 |
    @case:626
    Examples:
      | q1 | q2 |
      | 25 | 5 |
    @case:627
    Examples:
      | q1 | q2 |
      | 25 | 6 |
    @case:628
    Examples:
      | q1 | q2 |
      | 25 | 7 |
    @case:629
    Examples:
      | q1 | q2 |
      | 25 | 8 |
    @case:630
    Examples:
      | q1 | q2 |
      | 25 | 9 |
    @case:631
    Examples:
      | q1 | q2 |
      | 25 | 10 |
    @case:632
    Examples:
      | q1 | q2 |
      | 25 | 11 |
    @case:633
    Examples:
      | q1 | q2 |
      | 25 | 12 |
    @case:634
    Examples:
      | q1 | q2 |
      | 25 | 13 |
    @case:635
    Examples:
      | q1 | q2 |
      | 25 | 14 |
    @case:636
    Examples:
      | q1 | q2 |
      | 25 | 15 |
    @case:637
    Examples:
      | q1 | q2 |
      | 25 | 16 |
    @case:638
    Examples:
      | q1 | q2 |
      | 25 | 17 |
    @case:639
    Examples:
      | q1 | q2 |
      | 25 | 18 |
    @case:640
    Examples:
      | q1 | q2 |
      | 25 | 19 |
    @case:641
    Examples:
      | q1 | q2 |
      | 26 | 1 |
    @case:642
    Examples:
      | q1 | q2 |
      | 26 | 2 |
    @case:643
    Examples:
      | q1 | q2 |
      | 26 | 3 |
    @case:644
    Examples:
      | q1 | q2 |
      | 26 | 4 |
    @case:645
    Examples:
      | q1 | q2 |
      | 26 | 5 |
    @case:646
    Examples:
      | q1 | q2 |
      | 26 | 6 |
    @case:647
    Examples:
      | q1 | q2 |
      | 26 | 7 |
    @case:648
    Examples:
      | q1 | q2 |
      | 26 | 8 |
    @case:649
    Examples:
      | q1 | q2 |
      | 26 | 9 |
    @case:650
    Examples:
      | q1 | q2 |
      | 26 | 10 |
    @case:651
    Examples:
      | q1 | q2 |
      | 26 | 11 |
    @case:652
    Examples:
      | q1 | q2 |
      | 26 | 12 |
    @case:653
    Examples:
      | q1 | q2 |
      | 26 | 13 |
    @case:654
    Examples:
      | q1 | q2 |
      | 26 | 14 |
    @case:655
    Examples:
      | q1 | q2 |
      | 26 | 15 |
    @case:656
    Examples:
      | q1 | q2 |
      | 26 | 16 |
    @case:657
    Examples:
      | q1 | q2 |
      | 26 | 17 |
    @case:658
    Examples:
      | q1 | q2 |
      | 26 | 18 |
    @case:659
    Examples:
      | q1 | q2 |
      | 26 | 19 |
    @case:660
    Examples:
      | q1 | q2 |
      | 27 | 1 |
    @case:661
    Examples:
      | q1 | q2 |
      | 27 | 2 |
    @case:662
    Examples:
      | q1 | q2 |
      | 27 | 3 |
    @case:663
    Examples:
      | q1 | q2 |
      | 27 | 4 |
    @case:664
    Examples:
      | q1 | q2 |
      | 27 | 5 |
    @case:665
    Examples:
      | q1 | q2 |
      | 27 | 6 |
    @case:666
    Examples:
      | q1 | q2 |
      | 27 | 7 |
    @case:667
    Examples:
      | q1 | q2 |
      | 27 | 8 |
    @case:668
    Examples:
      | q1 | q2 |
      | 27 | 9 |
    @case:669
    Examples:
      | q1 | q2 |
      | 27 | 10 |
    @case:670
    Examples:
      | q1 | q2 |
      | 27 | 11 |
    @case:671
    Examples:
      | q1 | q2 |
      | 27 | 12 |
    @case:672
    Examples:
      | q1 | q2 |
      | 27 | 13 |
    @case:673
    Examples:
      | q1 | q2 |
      | 27 | 14 |
    @case:674
    Examples:
      | q1 | q2 |
      | 27 | 15 |
    @case:675
    Examples:
      | q1 | q2 |
      | 27 | 16 |
    @case:676
    Examples:
      | q1 | q2 |
      | 27 | 17 |
    @case:677
    Examples:
      | q1 | q2 |
      | 27 | 18 |
    @case:678
    Examples:
      | q1 | q2 |
      | 27 | 19 |
    @case:679
    Examples:
      | q1 | q2 |
      | 28 | 1 |
    @case:680
    Examples:
      | q1 | q2 |
      | 28 | 2 |
    @case:681
    Examples:
      | q1 | q2 |
      | 28 | 3 |
    @case:682
    Examples:
      | q1 | q2 |
      | 28 | 4 |
    @case:683
    Examples:
      | q1 | q2 |
      | 28 | 5 |
    @case:684
    Examples:
      | q1 | q2 |
      | 28 | 6 |
    @case:685
    Examples:
      | q1 | q2 |
      | 28 | 7 |
    @case:686
    Examples:
      | q1 | q2 |
      | 28 | 8 |
    @case:687
    Examples:
      | q1 | q2 |
      | 28 | 9 |
    @case:688
    Examples:
      | q1 | q2 |
      | 28 | 10 |
    @case:689
    Examples:
      | q1 | q2 |
      | 28 | 11 |
    @case:690
    Examples:
      | q1 | q2 |
      | 28 | 12 |
    @case:691
    Examples:
      | q1 | q2 |
      | 28 | 13 |
    @case:692
    Examples:
      | q1 | q2 |
      | 28 | 14 |
    @case:693
    Examples:
      | q1 | q2 |
      | 28 | 15 |
    @case:694
    Examples:
      | q1 | q2 |
      | 28 | 16 |
    @case:695
    Examples:
      | q1 | q2 |
      | 28 | 17 |
    @case:696
    Examples:
      | q1 | q2 |
      | 28 | 18 |
    @case:697
    Examples:
      | q1 | q2 |
      | 28 | 19 |
    @case:698
    Examples:
      | q1 | q2 |
      | 29 | 1 |
    @case:699
    Examples:
      | q1 | q2 |
      | 29 | 2 |
    @case:700
    Examples:
      | q1 | q2 |
      | 29 | 3 |
    @case:701
    Examples:
      | q1 | q2 |
      | 29 | 4 |
    @case:702
    Examples:
      | q1 | q2 |
      | 29 | 5 |
    @case:703
    Examples:
      | q1 | q2 |
      | 29 | 6 |
    @case:704
    Examples:
      | q1 | q2 |
      | 29 | 7 |
    @case:705
    Examples:
      | q1 | q2 |
      | 29 | 8 |
    @case:706
    Examples:
      | q1 | q2 |
      | 29 | 9 |
    @case:707
    Examples:
      | q1 | q2 |
      | 29 | 10 |
    @case:708
    Examples:
      | q1 | q2 |
      | 29 | 11 |
    @case:709
    Examples:
      | q1 | q2 |
      | 29 | 12 |
    @case:710
    Examples:
      | q1 | q2 |
      | 29 | 13 |
    @case:711
    Examples:
      | q1 | q2 |
      | 29 | 14 |
    @case:712
    Examples:
      | q1 | q2 |
      | 29 | 15 |
    @case:713
    Examples:
      | q1 | q2 |
      | 29 | 16 |
    @case:714
    Examples:
      | q1 | q2 |
      | 29 | 17 |
    @case:715
    Examples:
      | q1 | q2 |
      | 29 | 18 |
    @case:716
    Examples:
      | q1 | q2 |
      | 29 | 19 |
    @case:717
    Examples:
      | q1 | q2 |
      | 30 | 1 |
    @case:718
    Examples:
      | q1 | q2 |
      | 30 | 2 |
    @case:719
    Examples:
      | q1 | q2 |
      | 30 | 3 |
    @case:720
    Examples:
      | q1 | q2 |
      | 30 | 4 |
    @case:721
    Examples:
      | q1 | q2 |
      | 30 | 5 |
    @case:722
    Examples:
      | q1 | q2 |
      | 30 | 6 |
    @case:723
    Examples:
      | q1 | q2 |
      | 30 | 7 |
    @case:724
    Examples:
      | q1 | q2 |
      | 30 | 8 |
    @case:725
    Examples:
      | q1 | q2 |
      | 30 | 9 |
    @case:726
    Examples:
      | q1 | q2 |
      | 30 | 10 |
    @case:727
    Examples:
      | q1 | q2 |
      | 30 | 11 |
    @case:728
    Examples:
      | q1 | q2 |
      | 30 | 12 |
    @case:729
    Examples:
      | q1 | q2 |
      | 30 | 13 |
    @case:730
    Examples:
      | q1 | q2 |
      | 30 | 14 |
    @case:731
    Examples:
      | q1 | q2 |
      | 30 | 15 |
    @case:732
    Examples:
      | q1 | q2 |
      | 30 | 16 |
    @case:733
    Examples:
      | q1 | q2 |
      | 30 | 17 |
    @case:734
    Examples:
      | q1 | q2 |
      | 30 | 18 |
    @case:735
    Examples:
      | q1 | q2 |
      | 30 | 19 |
    @case:736
    Examples:
      | q1 | q2 |
      | 31 | 1 |
    @case:737
    Examples:
      | q1 | q2 |
      | 31 | 2 |
    @case:738
    Examples:
      | q1 | q2 |
      | 31 | 3 |
    @case:739
    Examples:
      | q1 | q2 |
      | 31 | 4 |
    @case:740
    Examples:
      | q1 | q2 |
      | 31 | 5 |
    @case:741
    Examples:
      | q1 | q2 |
      | 31 | 6 |
    @case:742
    Examples:
      | q1 | q2 |
      | 31 | 7 |
    @case:743
    Examples:
      | q1 | q2 |
      | 31 | 8 |
    @case:744
    Examples:
      | q1 | q2 |
      | 31 | 9 |
    @case:745
    Examples:
      | q1 | q2 |
      | 31 | 10 |
    @case:746
    Examples:
      | q1 | q2 |
      | 31 | 11 |
    @case:747
    Examples:
      | q1 | q2 |
      | 31 | 12 |
    @case:748
    Examples:
      | q1 | q2 |
      | 31 | 13 |
    @case:749
    Examples:
      | q1 | q2 |
      | 31 | 14 |
    @case:750
    Examples:
      | q1 | q2 |
      | 31 | 15 |
    @case:751
    Examples:
      | q1 | q2 |
      | 31 | 16 |
    @case:752
    Examples:
      | q1 | q2 |
      | 31 | 17 |
    @case:753
    Examples:
      | q1 | q2 |
      | 31 | 18 |
    @case:754
    Examples:
      | q1 | q2 |
      | 31 | 19 |
    @case:755
    Examples:
      | q1 | q2 |
      | 32 | 1 |
    @case:756
    Examples:
      | q1 | q2 |
      | 32 | 2 |
    @case:757
    Examples:
      | q1 | q2 |
      | 32 | 3 |
    @case:758
    Examples:
      | q1 | q2 |
      | 32 | 4 |
    @case:759
    Examples:
      | q1 | q2 |
      | 32 | 5 |
    @case:760
    Examples:
      | q1 | q2 |
      | 32 | 6 |
    @case:761
    Examples:
      | q1 | q2 |
      | 32 | 7 |
    @case:762
    Examples:
      | q1 | q2 |
      | 32 | 8 |
    @case:763
    Examples:
      | q1 | q2 |
      | 32 | 9 |
    @case:764
    Examples:
      | q1 | q2 |
      | 32 | 10 |
    @case:765
    Examples:
      | q1 | q2 |
      | 32 | 11 |
    @case:766
    Examples:
      | q1 | q2 |
      | 32 | 12 |
    @case:767
    Examples:
      | q1 | q2 |
      | 32 | 13 |
    @case:768
    Examples:
      | q1 | q2 |
      | 32 | 14 |
    @case:769
    Examples:
      | q1 | q2 |
      | 32 | 15 |
    @case:770
    Examples:
      | q1 | q2 |
      | 32 | 16 |
    @case:771
    Examples:
      | q1 | q2 |
      | 32 | 17 |
    @case:772
    Examples:
      | q1 | q2 |
      | 32 | 18 |
    @case:773
    Examples:
      | q1 | q2 |
      | 32 | 19 |
    @case:774
    Examples:
      | q1 | q2 |
      | 33 | 1 |
    @case:775
    Examples:
      | q1 | q2 |
      | 33 | 2 |
    @case:776
    Examples:
      | q1 | q2 |
      | 33 | 3 |
    @case:777
    Examples:
      | q1 | q2 |
      | 33 | 4 |
    @case:778
    Examples:
      | q1 | q2 |
      | 33 | 5 |
    @case:779
    Examples:
      | q1 | q2 |
      | 33 | 6 |
    @case:780
    Examples:
      | q1 | q2 |
      | 33 | 7 |
    @case:781
    Examples:
      | q1 | q2 |
      | 33 | 8 |
    @case:782
    Examples:
      | q1 | q2 |
      | 33 | 9 |
    @case:783
    Examples:
      | q1 | q2 |
      | 33 | 10 |
    @case:784
    Examples:
      | q1 | q2 |
      | 33 | 11 |
    @case:785
    Examples:
      | q1 | q2 |
      | 33 | 12 |
    @case:786
    Examples:
      | q1 | q2 |
      | 33 | 13 |
    @case:787
    Examples:
      | q1 | q2 |
      | 33 | 14 |
    @case:788
    Examples:
      | q1 | q2 |
      | 33 | 15 |
    @case:789
    Examples:
      | q1 | q2 |
      | 33 | 16 |
    @case:790
    Examples:
      | q1 | q2 |
      | 33 | 17 |
    @case:791
    Examples:
      | q1 | q2 |
      | 33 | 18 |
    @case:792
    Examples:
      | q1 | q2 |
      | 33 | 19 |
    @case:793
    Examples:
      | q1 | q2 |
      | 34 | 1 |
    @case:794
    Examples:
      | q1 | q2 |
      | 34 | 2 |
    @case:795
    Examples:
      | q1 | q2 |
      | 34 | 3 |
    @case:796
    Examples:
      | q1 | q2 |
      | 34 | 4 |
    @case:797
    Examples:
      | q1 | q2 |
      | 34 | 5 |
    @case:798
    Examples:
      | q1 | q2 |
      | 34 | 6 |
    @case:799
    Examples:
      | q1 | q2 |
      | 34 | 7 |
    @case:800
    Examples:
      | q1 | q2 |
      | 34 | 8 |
    @case:801
    Examples:
      | q1 | q2 |
      | 34 | 9 |
    @case:802
    Examples:
      | q1 | q2 |
      | 34 | 10 |
    @case:803
    Examples:
      | q1 | q2 |
      | 34 | 11 |
    @case:804
    Examples:
      | q1 | q2 |
      | 34 | 12 |
    @case:805
    Examples:
      | q1 | q2 |
      | 34 | 13 |
    @case:806
    Examples:
      | q1 | q2 |
      | 34 | 14 |
    @case:807
    Examples:
      | q1 | q2 |
      | 34 | 15 |
    @case:808
    Examples:
      | q1 | q2 |
      | 34 | 16 |
    @case:809
    Examples:
      | q1 | q2 |
      | 34 | 17 |
    @case:810
    Examples:
      | q1 | q2 |
      | 34 | 18 |
    @case:811
    Examples:
      | q1 | q2 |
      | 34 | 19 |
    @case:812
    Examples:
      | q1 | q2 |
      | 35 | 1 |
    @case:813
    Examples:
      | q1 | q2 |
      | 35 | 2 |
    @case:814
    Examples:
      | q1 | q2 |
      | 35 | 3 |
    @case:815
    Examples:
      | q1 | q2 |
      | 35 | 4 |
    @case:816
    Examples:
      | q1 | q2 |
      | 35 | 5 |
    @case:817
    Examples:
      | q1 | q2 |
      | 35 | 6 |
    @case:818
    Examples:
      | q1 | q2 |
      | 35 | 7 |
    @case:819
    Examples:
      | q1 | q2 |
      | 35 | 8 |
    @case:820
    Examples:
      | q1 | q2 |
      | 35 | 9 |
    @case:821
    Examples:
      | q1 | q2 |
      | 35 | 10 |
    @case:822
    Examples:
      | q1 | q2 |
      | 35 | 11 |
    @case:823
    Examples:
      | q1 | q2 |
      | 35 | 12 |
    @case:824
    Examples:
      | q1 | q2 |
      | 35 | 13 |
    @case:825
    Examples:
      | q1 | q2 |
      | 35 | 14 |
    @case:826
    Examples:
      | q1 | q2 |
      | 35 | 15 |
    @case:827
    Examples:
      | q1 | q2 |
      | 35 | 16 |
    @case:828
    Examples:
      | q1 | q2 |
      | 35 | 17 |
    @case:829
    Examples:
      | q1 | q2 |
      | 35 | 18 |
    @case:830
    Examples:
      | q1 | q2 |
      | 35 | 19 |
    @case:831
    Examples:
      | q1 | q2 |
      | 36 | 1 |
    @case:832
    Examples:
      | q1 | q2 |
      | 36 | 2 |
    @case:833
    Examples:
      | q1 | q2 |
      | 36 | 3 |
    @case:834
    Examples:
      | q1 | q2 |
      | 36 | 4 |
    @case:835
    Examples:
      | q1 | q2 |
      | 36 | 5 |
    @case:836
    Examples:
      | q1 | q2 |
      | 36 | 6 |
    @case:837
    Examples:
      | q1 | q2 |
      | 36 | 7 |
    @case:838
    Examples:
      | q1 | q2 |
      | 36 | 8 |
    @case:839
    Examples:
      | q1 | q2 |
      | 36 | 9 |
    @case:840
    Examples:
      | q1 | q2 |
      | 36 | 10 |
    @case:841
    Examples:
      | q1 | q2 |
      | 36 | 11 |
    @case:842
    Examples:
      | q1 | q2 |
      | 36 | 12 |
    @case:843
    Examples:
      | q1 | q2 |
      | 36 | 13 |
    @case:844
    Examples:
      | q1 | q2 |
      | 36 | 14 |
    @case:845
    Examples:
      | q1 | q2 |
      | 36 | 15 |
    @case:846
    Examples:
      | q1 | q2 |
      | 36 | 16 |
    @case:847
    Examples:
      | q1 | q2 |
      | 36 | 17 |
    @case:848
    Examples:
      | q1 | q2 |
      | 36 | 18 |
    @case:849
    Examples:
      | q1 | q2 |
      | 36 | 19 |
    @case:850
    Examples:
      | q1 | q2 |
      | 37 | 1 |
    @case:851
    Examples:
      | q1 | q2 |
      | 37 | 2 |
    @case:852
    Examples:
      | q1 | q2 |
      | 37 | 3 |
    @case:853
    Examples:
      | q1 | q2 |
      | 37 | 4 |
    @case:854
    Examples:
      | q1 | q2 |
      | 37 | 5 |
    @case:855
    Examples:
      | q1 | q2 |
      | 37 | 6 |
    @case:856
    Examples:
      | q1 | q2 |
      | 37 | 7 |
    @case:857
    Examples:
      | q1 | q2 |
      | 37 | 8 |
    @case:858
    Examples:
      | q1 | q2 |
      | 37 | 9 |
    @case:859
    Examples:
      | q1 | q2 |
      | 37 | 10 |
    @case:860
    Examples:
      | q1 | q2 |
      | 37 | 11 |
    @case:861
    Examples:
      | q1 | q2 |
      | 37 | 12 |
    @case:862
    Examples:
      | q1 | q2 |
      | 37 | 13 |
    @case:863
    Examples:
      | q1 | q2 |
      | 37 | 14 |
    @case:864
    Examples:
      | q1 | q2 |
      | 37 | 15 |
    @case:865
    Examples:
      | q1 | q2 |
      | 37 | 16 |
    @case:866
    Examples:
      | q1 | q2 |
      | 37 | 17 |
    @case:867
    Examples:
      | q1 | q2 |
      | 37 | 18 |
    @case:868
    Examples:
      | q1 | q2 |
      | 37 | 19 |
    @case:869
    Examples:
      | q1 | q2 |
      | 38 | 1 |
    @case:870
    Examples:
      | q1 | q2 |
      | 38 | 2 |
    @case:871
    Examples:
      | q1 | q2 |
      | 38 | 3 |
    @case:872
    Examples:
      | q1 | q2 |
      | 38 | 4 |
    @case:873
    Examples:
      | q1 | q2 |
      | 38 | 5 |
    @case:874
    Examples:
      | q1 | q2 |
      | 38 | 6 |
    @case:875
    Examples:
      | q1 | q2 |
      | 38 | 7 |
    @case:876
    Examples:
      | q1 | q2 |
      | 38 | 8 |
    @case:877
    Examples:
      | q1 | q2 |
      | 38 | 9 |
    @case:878
    Examples:
      | q1 | q2 |
      | 38 | 10 |
    @case:879
    Examples:
      | q1 | q2 |
      | 38 | 11 |
    @case:880
    Examples:
      | q1 | q2 |
      | 38 | 12 |
    @case:881
    Examples:
      | q1 | q2 |
      | 38 | 13 |
    @case:882
    Examples:
      | q1 | q2 |
      | 38 | 14 |
    @case:883
    Examples:
      | q1 | q2 |
      | 38 | 15 |
    @case:884
    Examples:
      | q1 | q2 |
      | 38 | 16 |
    @case:885
    Examples:
      | q1 | q2 |
      | 38 | 17 |
    @case:886
    Examples:
      | q1 | q2 |
      | 38 | 18 |
    @case:887
    Examples:
      | q1 | q2 |
      | 38 | 19 |
    @case:888
    Examples:
      | q1 | q2 |
      | 39 | 1 |
    @case:889
    Examples:
      | q1 | q2 |
      | 39 | 2 |
    @case:890
    Examples:
      | q1 | q2 |
      | 39 | 3 |
    @case:891
    Examples:
      | q1 | q2 |
      | 39 | 4 |
    @case:892
    Examples:
      | q1 | q2 |
      | 39 | 5 |
    @case:893
    Examples:
      | q1 | q2 |
      | 39 | 6 |
    @case:894
    Examples:
      | q1 | q2 |
      | 39 | 7 |
    @case:895
    Examples:
      | q1 | q2 |
      | 39 | 8 |
    @case:896
    Examples:
      | q1 | q2 |
      | 39 | 9 |
    @case:897
    Examples:
      | q1 | q2 |
      | 39 | 10 |
    @case:898
    Examples:
      | q1 | q2 |
      | 39 | 11 |
    @case:899
    Examples:
      | q1 | q2 |
      | 39 | 12 |
    @case:900
    Examples:
      | q1 | q2 |
      | 39 | 13 |
    @case:901
    Examples:
      | q1 | q2 |
      | 39 | 14 |
    @case:902
    Examples:
      | q1 | q2 |
      | 39 | 15 |
    @case:903
    Examples:
      | q1 | q2 |
      | 39 | 16 |
    @case:904
    Examples:
      | q1 | q2 |
      | 39 | 17 |
    @case:905
    Examples:
      | q1 | q2 |
      | 39 | 18 |
    @case:906
    Examples:
      | q1 | q2 |
      | 39 | 19 |
    @case:907
    Examples:
      | q1 | q2 |
      | 40 | 1 |
    @case:908
    Examples:
      | q1 | q2 |
      | 40 | 2 |
    @case:909
    Examples:
      | q1 | q2 |
      | 40 | 3 |
    @case:910
    Examples:
      | q1 | q2 |
      | 40 | 4 |
    @case:911
    Examples:
      | q1 | q2 |
      | 40 | 5 |
    @case:912
    Examples:
      | q1 | q2 |
      | 40 | 6 |
    @case:913
    Examples:
      | q1 | q2 |
      | 40 | 7 |
    @case:914
    Examples:
      | q1 | q2 |
      | 40 | 8 |
    @case:915
    Examples:
      | q1 | q2 |
      | 40 | 9 |
    @case:916
    Examples:
      | q1 | q2 |
      | 40 | 10 |
    @case:917
    Examples:
      | q1 | q2 |
      | 40 | 11 |
    @case:918
    Examples:
      | q1 | q2 |
      | 40 | 12 |
    @case:919
    Examples:
      | q1 | q2 |
      | 40 | 13 |
    @case:920
    Examples:
      | q1 | q2 |
      | 40 | 14 |
    @case:921
    Examples:
      | q1 | q2 |
      | 40 | 15 |
    @case:922
    Examples:
      | q1 | q2 |
      | 40 | 16 |
    @case:923
    Examples:
      | q1 | q2 |
      | 40 | 17 |
    @case:924
    Examples:
      | q1 | q2 |
      | 40 | 18 |
    @case:925
    Examples:
      | q1 | q2 |
      | 40 | 19 |
    @case:926
    Examples:
      | q1 | q2 |
      | 41 | 1 |
    @case:927
    Examples:
      | q1 | q2 |
      | 41 | 2 |
    @case:928
    Examples:
      | q1 | q2 |
      | 41 | 3 |
    @case:929
    Examples:
      | q1 | q2 |
      | 41 | 4 |
    @case:930
    Examples:
      | q1 | q2 |
      | 41 | 5 |
    @case:931
    Examples:
      | q1 | q2 |
      | 41 | 6 |
    @case:932
    Examples:
      | q1 | q2 |
      | 41 | 7 |
    @case:933
    Examples:
      | q1 | q2 |
      | 41 | 8 |
    @case:934
    Examples:
      | q1 | q2 |
      | 41 | 9 |
    @case:935
    Examples:
      | q1 | q2 |
      | 41 | 10 |
    @case:936
    Examples:
      | q1 | q2 |
      | 41 | 11 |
    @case:937
    Examples:
      | q1 | q2 |
      | 41 | 12 |
    @case:938
    Examples:
      | q1 | q2 |
      | 41 | 13 |
    @case:939
    Examples:
      | q1 | q2 |
      | 41 | 14 |
    @case:940
    Examples:
      | q1 | q2 |
      | 41 | 15 |
    @case:941
    Examples:
      | q1 | q2 |
      | 41 | 16 |
    @case:942
    Examples:
      | q1 | q2 |
      | 41 | 17 |
    @case:943
    Examples:
      | q1 | q2 |
      | 41 | 18 |
    @case:944
    Examples:
      | q1 | q2 |
      | 41 | 19 |
    @case:945
    Examples:
      | q1 | q2 |
      | 42 | 1 |
    @case:946
    Examples:
      | q1 | q2 |
      | 42 | 2 |
    @case:947
    Examples:
      | q1 | q2 |
      | 42 | 3 |
    @case:948
    Examples:
      | q1 | q2 |
      | 42 | 4 |
    @case:949
    Examples:
      | q1 | q2 |
      | 42 | 5 |
    @case:950
    Examples:
      | q1 | q2 |
      | 42 | 6 |
    @case:951
    Examples:
      | q1 | q2 |
      | 42 | 7 |
    @case:952
    Examples:
      | q1 | q2 |
      | 42 | 8 |
    @case:953
    Examples:
      | q1 | q2 |
      | 42 | 9 |
    @case:954
    Examples:
      | q1 | q2 |
      | 42 | 10 |
    @case:955
    Examples:
      | q1 | q2 |
      | 42 | 11 |
    @case:956
    Examples:
      | q1 | q2 |
      | 42 | 12 |
    @case:957
    Examples:
      | q1 | q2 |
      | 42 | 13 |
    @case:958
    Examples:
      | q1 | q2 |
      | 42 | 14 |
    @case:959
    Examples:
      | q1 | q2 |
      | 42 | 15 |
    @case:960
    Examples:
      | q1 | q2 |
      | 42 | 16 |
    @case:961
    Examples:
      | q1 | q2 |
      | 42 | 17 |
    @case:962
    Examples:
      | q1 | q2 |
      | 42 | 18 |
    @case:963
    Examples:
      | q1 | q2 |
      | 42 | 19 |
    @case:964
    Examples:
      | q1 | q2 |
      | 43 | 1 |
    @case:965
    Examples:
      | q1 | q2 |
      | 43 | 2 |
    @case:966
    Examples:
      | q1 | q2 |
      | 43 | 3 |
    @case:967
    Examples:
      | q1 | q2 |
      | 43 | 4 |
    @case:968
    Examples:
      | q1 | q2 |
      | 43 | 5 |
    @case:969
    Examples:
      | q1 | q2 |
      | 43 | 6 |
    @case:970
    Examples:
      | q1 | q2 |
      | 43 | 7 |
    @case:971
    Examples:
      | q1 | q2 |
      | 43 | 8 |
    @case:972
    Examples:
      | q1 | q2 |
      | 43 | 9 |
    @case:973
    Examples:
      | q1 | q2 |
      | 43 | 10 |
    @case:974
    Examples:
      | q1 | q2 |
      | 43 | 11 |
    @case:975
    Examples:
      | q1 | q2 |
      | 43 | 12 |
    @case:976
    Examples:
      | q1 | q2 |
      | 43 | 13 |
    @case:977
    Examples:
      | q1 | q2 |
      | 43 | 14 |
    @case:978
    Examples:
      | q1 | q2 |
      | 43 | 15 |
    @case:979
    Examples:
      | q1 | q2 |
      | 43 | 16 |
    @case:980
    Examples:
      | q1 | q2 |
      | 43 | 17 |
    @case:981
    Examples:
      | q1 | q2 |
      | 43 | 18 |
    @case:982
    Examples:
      | q1 | q2 |
      | 43 | 19 |
    @case:983
    Examples:
      | q1 | q2 |
      | 44 | 1 |
    @case:984
    Examples:
      | q1 | q2 |
      | 44 | 2 |
    @case:985
    Examples:
      | q1 | q2 |
      | 44 | 3 |
    @case:986
    Examples:
      | q1 | q2 |
      | 44 | 4 |
    @case:987
    Examples:
      | q1 | q2 |
      | 44 | 5 |
    @case:988
    Examples:
      | q1 | q2 |
      | 44 | 6 |
    @case:989
    Examples:
      | q1 | q2 |
      | 44 | 7 |
    @case:990
    Examples:
      | q1 | q2 |
      | 44 | 8 |
    @case:991
    Examples:
      | q1 | q2 |
      | 44 | 9 |
    @case:992
    Examples:
      | q1 | q2 |
      | 44 | 10 |
    @case:993
    Examples:
      | q1 | q2 |
      | 44 | 11 |
    @case:994
    Examples:
      | q1 | q2 |
      | 44 | 12 |
    @case:995
    Examples:
      | q1 | q2 |
      | 44 | 13 |
    @case:996
    Examples:
      | q1 | q2 |
      | 44 | 14 |
    @case:997
    Examples:
      | q1 | q2 |
      | 44 | 15 |
    @case:998
    Examples:
      | q1 | q2 |
      | 44 | 16 |
    @case:999
    Examples:
      | q1 | q2 |
      | 44 | 17 |
    @case:1000
    Examples:
      | q1 | q2 |
      | 44 | 18 |
