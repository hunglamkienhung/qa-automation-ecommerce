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

  Scenario Outline: The TENOFF coupon at subtotal <subtotal> applies a flat 1000 discount
    When the coupon "TENOFF" is applied to a subtotal of <subtotal>
    Then the response field "discount_cents" is 1000

    @case:346
    Examples:
      | subtotal |
      | 5000 |
    @case:347
    Examples:
      | subtotal |
      | 5100 |
    @case:348
    Examples:
      | subtotal |
      | 5200 |
    @case:349
    Examples:
      | subtotal |
      | 5300 |
    @case:350
    Examples:
      | subtotal |
      | 5400 |
    @case:351
    Examples:
      | subtotal |
      | 5500 |
    @case:352
    Examples:
      | subtotal |
      | 5600 |
    @case:353
    Examples:
      | subtotal |
      | 5700 |
    @case:354
    Examples:
      | subtotal |
      | 5800 |
    @case:355
    Examples:
      | subtotal |
      | 5900 |
    @case:356
    Examples:
      | subtotal |
      | 6000 |
    @case:357
    Examples:
      | subtotal |
      | 6100 |
    @case:358
    Examples:
      | subtotal |
      | 6200 |
    @case:359
    Examples:
      | subtotal |
      | 6300 |
    @case:360
    Examples:
      | subtotal |
      | 6400 |
    @case:361
    Examples:
      | subtotal |
      | 6500 |
    @case:362
    Examples:
      | subtotal |
      | 6600 |
    @case:363
    Examples:
      | subtotal |
      | 6700 |
    @case:364
    Examples:
      | subtotal |
      | 6800 |
    @case:365
    Examples:
      | subtotal |
      | 6900 |
    @case:366
    Examples:
      | subtotal |
      | 7000 |
    @case:367
    Examples:
      | subtotal |
      | 7100 |
    @case:368
    Examples:
      | subtotal |
      | 7200 |
    @case:369
    Examples:
      | subtotal |
      | 7300 |
    @case:370
    Examples:
      | subtotal |
      | 7400 |
    @case:371
    Examples:
      | subtotal |
      | 7500 |
    @case:372
    Examples:
      | subtotal |
      | 7600 |
    @case:373
    Examples:
      | subtotal |
      | 7700 |
    @case:374
    Examples:
      | subtotal |
      | 7800 |
    @case:375
    Examples:
      | subtotal |
      | 7900 |
    @case:376
    Examples:
      | subtotal |
      | 8000 |
    @case:377
    Examples:
      | subtotal |
      | 8100 |
    @case:378
    Examples:
      | subtotal |
      | 8200 |
    @case:379
    Examples:
      | subtotal |
      | 8300 |
    @case:380
    Examples:
      | subtotal |
      | 8400 |
    @case:381
    Examples:
      | subtotal |
      | 8500 |
    @case:382
    Examples:
      | subtotal |
      | 8600 |
    @case:383
    Examples:
      | subtotal |
      | 8700 |
    @case:384
    Examples:
      | subtotal |
      | 8800 |
    @case:385
    Examples:
      | subtotal |
      | 8900 |
    @case:386
    Examples:
      | subtotal |
      | 9000 |
    @case:387
    Examples:
      | subtotal |
      | 9100 |
    @case:388
    Examples:
      | subtotal |
      | 9200 |
    @case:389
    Examples:
      | subtotal |
      | 9300 |
    @case:390
    Examples:
      | subtotal |
      | 9400 |
    @case:391
    Examples:
      | subtotal |
      | 9500 |
    @case:392
    Examples:
      | subtotal |
      | 9600 |
    @case:393
    Examples:
      | subtotal |
      | 9700 |
    @case:394
    Examples:
      | subtotal |
      | 9800 |
    @case:395
    Examples:
      | subtotal |
      | 9900 |
    @case:396
    Examples:
      | subtotal |
      | 10000 |
    @case:397
    Examples:
      | subtotal |
      | 10100 |
    @case:398
    Examples:
      | subtotal |
      | 10200 |
    @case:399
    Examples:
      | subtotal |
      | 10300 |
    @case:400
    Examples:
      | subtotal |
      | 10400 |
    @case:401
    Examples:
      | subtotal |
      | 10500 |
    @case:402
    Examples:
      | subtotal |
      | 10600 |
    @case:403
    Examples:
      | subtotal |
      | 10700 |
    @case:404
    Examples:
      | subtotal |
      | 10800 |
    @case:405
    Examples:
      | subtotal |
      | 10900 |
    @case:406
    Examples:
      | subtotal |
      | 11000 |
    @case:407
    Examples:
      | subtotal |
      | 11100 |
    @case:408
    Examples:
      | subtotal |
      | 11200 |
    @case:409
    Examples:
      | subtotal |
      | 11300 |
    @case:410
    Examples:
      | subtotal |
      | 11400 |
    @case:411
    Examples:
      | subtotal |
      | 11500 |
    @case:412
    Examples:
      | subtotal |
      | 11600 |
    @case:413
    Examples:
      | subtotal |
      | 11700 |
    @case:414
    Examples:
      | subtotal |
      | 11800 |
    @case:415
    Examples:
      | subtotal |
      | 11900 |
    @case:416
    Examples:
      | subtotal |
      | 12000 |
    @case:417
    Examples:
      | subtotal |
      | 12100 |
    @case:418
    Examples:
      | subtotal |
      | 12200 |
    @case:419
    Examples:
      | subtotal |
      | 12300 |
    @case:420
    Examples:
      | subtotal |
      | 12400 |
    @case:421
    Examples:
      | subtotal |
      | 12500 |
    @case:422
    Examples:
      | subtotal |
      | 12600 |
    @case:423
    Examples:
      | subtotal |
      | 12700 |
    @case:424
    Examples:
      | subtotal |
      | 12800 |
    @case:425
    Examples:
      | subtotal |
      | 12900 |
    @case:426
    Examples:
      | subtotal |
      | 13000 |
    @case:427
    Examples:
      | subtotal |
      | 13100 |
    @case:428
    Examples:
      | subtotal |
      | 13200 |
    @case:429
    Examples:
      | subtotal |
      | 13300 |
    @case:430
    Examples:
      | subtotal |
      | 13400 |
    @case:431
    Examples:
      | subtotal |
      | 13500 |
    @case:432
    Examples:
      | subtotal |
      | 13600 |
    @case:433
    Examples:
      | subtotal |
      | 13700 |
    @case:434
    Examples:
      | subtotal |
      | 13800 |
    @case:435
    Examples:
      | subtotal |
      | 13900 |
    @case:436
    Examples:
      | subtotal |
      | 14000 |
    @case:437
    Examples:
      | subtotal |
      | 14100 |
    @case:438
    Examples:
      | subtotal |
      | 14200 |
    @case:439
    Examples:
      | subtotal |
      | 14300 |
    @case:440
    Examples:
      | subtotal |
      | 14400 |
    @case:441
    Examples:
      | subtotal |
      | 14500 |
    @case:442
    Examples:
      | subtotal |
      | 14600 |
    @case:443
    Examples:
      | subtotal |
      | 14700 |
    @case:444
    Examples:
      | subtotal |
      | 14800 |
    @case:445
    Examples:
      | subtotal |
      | 14900 |
    @case:446
    Examples:
      | subtotal |
      | 15000 |
    @case:447
    Examples:
      | subtotal |
      | 15100 |
    @case:448
    Examples:
      | subtotal |
      | 15200 |
    @case:449
    Examples:
      | subtotal |
      | 15300 |
    @case:450
    Examples:
      | subtotal |
      | 15400 |
    @case:451
    Examples:
      | subtotal |
      | 15500 |
    @case:452
    Examples:
      | subtotal |
      | 15600 |
    @case:453
    Examples:
      | subtotal |
      | 15700 |
    @case:454
    Examples:
      | subtotal |
      | 15800 |
    @case:455
    Examples:
      | subtotal |
      | 15900 |
    @case:456
    Examples:
      | subtotal |
      | 16000 |
    @case:457
    Examples:
      | subtotal |
      | 16100 |
    @case:458
    Examples:
      | subtotal |
      | 16200 |
    @case:459
    Examples:
      | subtotal |
      | 16300 |
    @case:460
    Examples:
      | subtotal |
      | 16400 |
    @case:461
    Examples:
      | subtotal |
      | 16500 |
    @case:462
    Examples:
      | subtotal |
      | 16600 |
    @case:463
    Examples:
      | subtotal |
      | 16700 |
    @case:464
    Examples:
      | subtotal |
      | 16800 |
    @case:465
    Examples:
      | subtotal |
      | 16900 |
    @case:466
    Examples:
      | subtotal |
      | 17000 |
    @case:467
    Examples:
      | subtotal |
      | 17100 |
    @case:468
    Examples:
      | subtotal |
      | 17200 |
    @case:469
    Examples:
      | subtotal |
      | 17300 |
    @case:470
    Examples:
      | subtotal |
      | 17400 |

  Scenario Outline: The SAVE10 coupon on a subtotal of <subtotal> discounts <disc>
    When the coupon "SAVE10" is applied to a subtotal of <subtotal>
    Then the response field "discount_cents" is <disc>

    @case:471
    Examples:
      | subtotal | disc |
      | 100 | 10 |
    @case:472
    Examples:
      | subtotal | disc |
      | 200 | 20 |
    @case:473
    Examples:
      | subtotal | disc |
      | 300 | 30 |
    @case:474
    Examples:
      | subtotal | disc |
      | 400 | 40 |
    @case:475
    Examples:
      | subtotal | disc |
      | 500 | 50 |
    @case:476
    Examples:
      | subtotal | disc |
      | 600 | 60 |
    @case:477
    Examples:
      | subtotal | disc |
      | 700 | 70 |
    @case:478
    Examples:
      | subtotal | disc |
      | 800 | 80 |
    @case:479
    Examples:
      | subtotal | disc |
      | 900 | 90 |
    @case:480
    Examples:
      | subtotal | disc |
      | 1000 | 100 |
    @case:481
    Examples:
      | subtotal | disc |
      | 1100 | 110 |
    @case:482
    Examples:
      | subtotal | disc |
      | 1200 | 120 |
    @case:483
    Examples:
      | subtotal | disc |
      | 1300 | 130 |
    @case:484
    Examples:
      | subtotal | disc |
      | 1400 | 140 |
    @case:485
    Examples:
      | subtotal | disc |
      | 1500 | 150 |
    @case:486
    Examples:
      | subtotal | disc |
      | 1600 | 160 |
    @case:487
    Examples:
      | subtotal | disc |
      | 1700 | 170 |
    @case:488
    Examples:
      | subtotal | disc |
      | 1800 | 180 |
    @case:489
    Examples:
      | subtotal | disc |
      | 1900 | 190 |
    @case:490
    Examples:
      | subtotal | disc |
      | 2000 | 200 |
    @case:491
    Examples:
      | subtotal | disc |
      | 2100 | 210 |
    @case:492
    Examples:
      | subtotal | disc |
      | 2200 | 220 |
    @case:493
    Examples:
      | subtotal | disc |
      | 2300 | 230 |
    @case:494
    Examples:
      | subtotal | disc |
      | 2400 | 240 |
    @case:495
    Examples:
      | subtotal | disc |
      | 2500 | 250 |
    @case:496
    Examples:
      | subtotal | disc |
      | 2600 | 260 |
    @case:497
    Examples:
      | subtotal | disc |
      | 2700 | 270 |
    @case:498
    Examples:
      | subtotal | disc |
      | 2800 | 280 |
    @case:499
    Examples:
      | subtotal | disc |
      | 2900 | 290 |
    @case:500
    Examples:
      | subtotal | disc |
      | 3000 | 300 |
    @case:501
    Examples:
      | subtotal | disc |
      | 3100 | 310 |
    @case:502
    Examples:
      | subtotal | disc |
      | 3200 | 320 |
    @case:503
    Examples:
      | subtotal | disc |
      | 3300 | 330 |
    @case:504
    Examples:
      | subtotal | disc |
      | 3400 | 340 |
    @case:505
    Examples:
      | subtotal | disc |
      | 3500 | 350 |
    @case:506
    Examples:
      | subtotal | disc |
      | 3600 | 360 |
    @case:507
    Examples:
      | subtotal | disc |
      | 3700 | 370 |
    @case:508
    Examples:
      | subtotal | disc |
      | 3800 | 380 |
    @case:509
    Examples:
      | subtotal | disc |
      | 3900 | 390 |
    @case:510
    Examples:
      | subtotal | disc |
      | 4000 | 400 |
    @case:511
    Examples:
      | subtotal | disc |
      | 4100 | 410 |
    @case:512
    Examples:
      | subtotal | disc |
      | 4200 | 420 |
    @case:513
    Examples:
      | subtotal | disc |
      | 4300 | 430 |
    @case:514
    Examples:
      | subtotal | disc |
      | 4400 | 440 |
    @case:515
    Examples:
      | subtotal | disc |
      | 4500 | 450 |
    @case:516
    Examples:
      | subtotal | disc |
      | 4600 | 460 |
    @case:517
    Examples:
      | subtotal | disc |
      | 4700 | 470 |
    @case:518
    Examples:
      | subtotal | disc |
      | 4800 | 480 |
    @case:519
    Examples:
      | subtotal | disc |
      | 4900 | 490 |
    @case:520
    Examples:
      | subtotal | disc |
      | 5000 | 500 |
    @case:521
    Examples:
      | subtotal | disc |
      | 5100 | 510 |
    @case:522
    Examples:
      | subtotal | disc |
      | 5200 | 520 |
    @case:523
    Examples:
      | subtotal | disc |
      | 5300 | 530 |
    @case:524
    Examples:
      | subtotal | disc |
      | 5400 | 540 |
    @case:525
    Examples:
      | subtotal | disc |
      | 5500 | 550 |
    @case:526
    Examples:
      | subtotal | disc |
      | 5600 | 560 |
    @case:527
    Examples:
      | subtotal | disc |
      | 5700 | 570 |
    @case:528
    Examples:
      | subtotal | disc |
      | 5800 | 580 |
    @case:529
    Examples:
      | subtotal | disc |
      | 5900 | 590 |
    @case:530
    Examples:
      | subtotal | disc |
      | 6000 | 600 |
    @case:531
    Examples:
      | subtotal | disc |
      | 6100 | 610 |
    @case:532
    Examples:
      | subtotal | disc |
      | 6200 | 620 |
    @case:533
    Examples:
      | subtotal | disc |
      | 6300 | 630 |
    @case:534
    Examples:
      | subtotal | disc |
      | 6400 | 640 |
    @case:535
    Examples:
      | subtotal | disc |
      | 6500 | 650 |
    @case:536
    Examples:
      | subtotal | disc |
      | 6600 | 660 |
    @case:537
    Examples:
      | subtotal | disc |
      | 6700 | 670 |
    @case:538
    Examples:
      | subtotal | disc |
      | 6800 | 680 |
    @case:539
    Examples:
      | subtotal | disc |
      | 6900 | 690 |
    @case:540
    Examples:
      | subtotal | disc |
      | 7000 | 700 |
    @case:541
    Examples:
      | subtotal | disc |
      | 7100 | 710 |
    @case:542
    Examples:
      | subtotal | disc |
      | 7200 | 720 |
    @case:543
    Examples:
      | subtotal | disc |
      | 7300 | 730 |
    @case:544
    Examples:
      | subtotal | disc |
      | 7400 | 740 |
    @case:545
    Examples:
      | subtotal | disc |
      | 7500 | 750 |
    @case:546
    Examples:
      | subtotal | disc |
      | 7600 | 760 |
    @case:547
    Examples:
      | subtotal | disc |
      | 7700 | 770 |
    @case:548
    Examples:
      | subtotal | disc |
      | 7800 | 780 |
    @case:549
    Examples:
      | subtotal | disc |
      | 7900 | 790 |
    @case:550
    Examples:
      | subtotal | disc |
      | 8000 | 800 |
    @case:551
    Examples:
      | subtotal | disc |
      | 8100 | 810 |
    @case:552
    Examples:
      | subtotal | disc |
      | 8200 | 820 |
    @case:553
    Examples:
      | subtotal | disc |
      | 8300 | 830 |
    @case:554
    Examples:
      | subtotal | disc |
      | 8400 | 840 |
    @case:555
    Examples:
      | subtotal | disc |
      | 8500 | 850 |
    @case:556
    Examples:
      | subtotal | disc |
      | 8600 | 860 |
    @case:557
    Examples:
      | subtotal | disc |
      | 8700 | 870 |
    @case:558
    Examples:
      | subtotal | disc |
      | 8800 | 880 |
    @case:559
    Examples:
      | subtotal | disc |
      | 8900 | 890 |
    @case:560
    Examples:
      | subtotal | disc |
      | 9000 | 900 |
    @case:561
    Examples:
      | subtotal | disc |
      | 9100 | 910 |
    @case:562
    Examples:
      | subtotal | disc |
      | 9200 | 920 |
    @case:563
    Examples:
      | subtotal | disc |
      | 9300 | 930 |
    @case:564
    Examples:
      | subtotal | disc |
      | 9400 | 940 |
    @case:565
    Examples:
      | subtotal | disc |
      | 9500 | 950 |
    @case:566
    Examples:
      | subtotal | disc |
      | 9600 | 960 |
    @case:567
    Examples:
      | subtotal | disc |
      | 9700 | 970 |
    @case:568
    Examples:
      | subtotal | disc |
      | 9800 | 980 |
    @case:569
    Examples:
      | subtotal | disc |
      | 9900 | 990 |
    @case:570
    Examples:
      | subtotal | disc |
      | 10000 | 1000 |
    @case:571
    Examples:
      | subtotal | disc |
      | 10100 | 1010 |
    @case:572
    Examples:
      | subtotal | disc |
      | 10200 | 1020 |
    @case:573
    Examples:
      | subtotal | disc |
      | 10300 | 1030 |
    @case:574
    Examples:
      | subtotal | disc |
      | 10400 | 1040 |
    @case:575
    Examples:
      | subtotal | disc |
      | 10500 | 1050 |
    @case:576
    Examples:
      | subtotal | disc |
      | 10600 | 1060 |
    @case:577
    Examples:
      | subtotal | disc |
      | 10700 | 1070 |
    @case:578
    Examples:
      | subtotal | disc |
      | 10800 | 1080 |
    @case:579
    Examples:
      | subtotal | disc |
      | 10900 | 1090 |
    @case:580
    Examples:
      | subtotal | disc |
      | 11000 | 1100 |
    @case:581
    Examples:
      | subtotal | disc |
      | 11100 | 1110 |
    @case:582
    Examples:
      | subtotal | disc |
      | 11200 | 1120 |
    @case:583
    Examples:
      | subtotal | disc |
      | 11300 | 1130 |
    @case:584
    Examples:
      | subtotal | disc |
      | 11400 | 1140 |
    @case:585
    Examples:
      | subtotal | disc |
      | 11500 | 1150 |
    @case:586
    Examples:
      | subtotal | disc |
      | 11600 | 1160 |
    @case:587
    Examples:
      | subtotal | disc |
      | 11700 | 1170 |
    @case:588
    Examples:
      | subtotal | disc |
      | 11800 | 1180 |
    @case:589
    Examples:
      | subtotal | disc |
      | 11900 | 1190 |
    @case:590
    Examples:
      | subtotal | disc |
      | 12000 | 1200 |
    @case:591
    Examples:
      | subtotal | disc |
      | 12100 | 1210 |
    @case:592
    Examples:
      | subtotal | disc |
      | 12200 | 1220 |
    @case:593
    Examples:
      | subtotal | disc |
      | 12300 | 1230 |
    @case:594
    Examples:
      | subtotal | disc |
      | 12400 | 1240 |
    @case:595
    Examples:
      | subtotal | disc |
      | 12500 | 1250 |
    @case:596
    Examples:
      | subtotal | disc |
      | 12600 | 1260 |
    @case:597
    Examples:
      | subtotal | disc |
      | 12700 | 1270 |
    @case:598
    Examples:
      | subtotal | disc |
      | 12800 | 1280 |
    @case:599
    Examples:
      | subtotal | disc |
      | 12900 | 1290 |
    @case:600
    Examples:
      | subtotal | disc |
      | 13000 | 1300 |
    @case:601
    Examples:
      | subtotal | disc |
      | 13100 | 1310 |
    @case:602
    Examples:
      | subtotal | disc |
      | 13200 | 1320 |
    @case:603
    Examples:
      | subtotal | disc |
      | 13300 | 1330 |
    @case:604
    Examples:
      | subtotal | disc |
      | 13400 | 1340 |
    @case:605
    Examples:
      | subtotal | disc |
      | 13500 | 1350 |
    @case:606
    Examples:
      | subtotal | disc |
      | 13600 | 1360 |
    @case:607
    Examples:
      | subtotal | disc |
      | 13700 | 1370 |
    @case:608
    Examples:
      | subtotal | disc |
      | 13800 | 1380 |
    @case:609
    Examples:
      | subtotal | disc |
      | 13900 | 1390 |
    @case:610
    Examples:
      | subtotal | disc |
      | 14000 | 1400 |
    @case:611
    Examples:
      | subtotal | disc |
      | 14100 | 1410 |
    @case:612
    Examples:
      | subtotal | disc |
      | 14200 | 1420 |
    @case:613
    Examples:
      | subtotal | disc |
      | 14300 | 1430 |
    @case:614
    Examples:
      | subtotal | disc |
      | 14400 | 1440 |
    @case:615
    Examples:
      | subtotal | disc |
      | 14500 | 1450 |
    @case:616
    Examples:
      | subtotal | disc |
      | 14600 | 1460 |
    @case:617
    Examples:
      | subtotal | disc |
      | 14700 | 1470 |
    @case:618
    Examples:
      | subtotal | disc |
      | 14800 | 1480 |
    @case:619
    Examples:
      | subtotal | disc |
      | 14900 | 1490 |
    @case:620
    Examples:
      | subtotal | disc |
      | 15000 | 1500 |

  Scenario Outline: The SAVE10 discount never exceeds a subtotal of <subtotal>
    When the coupon "SAVE10" is applied to a subtotal of <subtotal>
    Then the response field "discount_cents" is at most the subtotal <subtotal>

    @case:621
    Examples:
      | subtotal |
      | 40 |
    @case:622
    Examples:
      | subtotal |
      | 77 |
    @case:623
    Examples:
      | subtotal |
      | 114 |
    @case:624
    Examples:
      | subtotal |
      | 151 |
    @case:625
    Examples:
      | subtotal |
      | 188 |
    @case:626
    Examples:
      | subtotal |
      | 225 |
    @case:627
    Examples:
      | subtotal |
      | 262 |
    @case:628
    Examples:
      | subtotal |
      | 299 |
    @case:629
    Examples:
      | subtotal |
      | 336 |
    @case:630
    Examples:
      | subtotal |
      | 373 |
    @case:631
    Examples:
      | subtotal |
      | 410 |
    @case:632
    Examples:
      | subtotal |
      | 447 |
    @case:633
    Examples:
      | subtotal |
      | 484 |
    @case:634
    Examples:
      | subtotal |
      | 521 |
    @case:635
    Examples:
      | subtotal |
      | 558 |
    @case:636
    Examples:
      | subtotal |
      | 595 |
    @case:637
    Examples:
      | subtotal |
      | 632 |
    @case:638
    Examples:
      | subtotal |
      | 669 |
    @case:639
    Examples:
      | subtotal |
      | 706 |
    @case:640
    Examples:
      | subtotal |
      | 743 |
    @case:641
    Examples:
      | subtotal |
      | 780 |
    @case:642
    Examples:
      | subtotal |
      | 817 |
    @case:643
    Examples:
      | subtotal |
      | 854 |
    @case:644
    Examples:
      | subtotal |
      | 891 |
    @case:645
    Examples:
      | subtotal |
      | 928 |
    @case:646
    Examples:
      | subtotal |
      | 965 |
    @case:647
    Examples:
      | subtotal |
      | 1002 |
    @case:648
    Examples:
      | subtotal |
      | 1039 |
    @case:649
    Examples:
      | subtotal |
      | 1076 |
    @case:650
    Examples:
      | subtotal |
      | 1113 |
    @case:651
    Examples:
      | subtotal |
      | 1150 |
    @case:652
    Examples:
      | subtotal |
      | 1187 |
    @case:653
    Examples:
      | subtotal |
      | 1224 |
    @case:654
    Examples:
      | subtotal |
      | 1261 |
    @case:655
    Examples:
      | subtotal |
      | 1298 |
    @case:656
    Examples:
      | subtotal |
      | 1335 |
    @case:657
    Examples:
      | subtotal |
      | 1372 |
    @case:658
    Examples:
      | subtotal |
      | 1409 |
    @case:659
    Examples:
      | subtotal |
      | 1446 |
    @case:660
    Examples:
      | subtotal |
      | 1483 |
    @case:661
    Examples:
      | subtotal |
      | 1520 |
    @case:662
    Examples:
      | subtotal |
      | 1557 |
    @case:663
    Examples:
      | subtotal |
      | 1594 |
    @case:664
    Examples:
      | subtotal |
      | 1631 |
    @case:665
    Examples:
      | subtotal |
      | 1668 |
    @case:666
    Examples:
      | subtotal |
      | 1705 |
    @case:667
    Examples:
      | subtotal |
      | 1742 |
    @case:668
    Examples:
      | subtotal |
      | 1779 |
    @case:669
    Examples:
      | subtotal |
      | 1816 |
    @case:670
    Examples:
      | subtotal |
      | 1853 |
    @case:671
    Examples:
      | subtotal |
      | 1890 |
    @case:672
    Examples:
      | subtotal |
      | 1927 |
    @case:673
    Examples:
      | subtotal |
      | 1964 |
    @case:674
    Examples:
      | subtotal |
      | 2001 |
    @case:675
    Examples:
      | subtotal |
      | 2038 |
    @case:676
    Examples:
      | subtotal |
      | 2075 |
    @case:677
    Examples:
      | subtotal |
      | 2112 |
    @case:678
    Examples:
      | subtotal |
      | 2149 |
    @case:679
    Examples:
      | subtotal |
      | 2186 |
    @case:680
    Examples:
      | subtotal |
      | 2223 |
    @case:681
    Examples:
      | subtotal |
      | 2260 |
    @case:682
    Examples:
      | subtotal |
      | 2297 |
    @case:683
    Examples:
      | subtotal |
      | 2334 |
    @case:684
    Examples:
      | subtotal |
      | 2371 |
    @case:685
    Examples:
      | subtotal |
      | 2408 |
    @case:686
    Examples:
      | subtotal |
      | 2445 |
    @case:687
    Examples:
      | subtotal |
      | 2482 |
    @case:688
    Examples:
      | subtotal |
      | 2519 |
    @case:689
    Examples:
      | subtotal |
      | 2556 |
    @case:690
    Examples:
      | subtotal |
      | 2593 |
    @case:691
    Examples:
      | subtotal |
      | 2630 |
    @case:692
    Examples:
      | subtotal |
      | 2667 |
    @case:693
    Examples:
      | subtotal |
      | 2704 |
    @case:694
    Examples:
      | subtotal |
      | 2741 |
    @case:695
    Examples:
      | subtotal |
      | 2778 |
    @case:696
    Examples:
      | subtotal |
      | 2815 |
    @case:697
    Examples:
      | subtotal |
      | 2852 |
    @case:698
    Examples:
      | subtotal |
      | 2889 |
    @case:699
    Examples:
      | subtotal |
      | 2926 |
    @case:700
    Examples:
      | subtotal |
      | 2963 |
    @case:701
    Examples:
      | subtotal |
      | 3000 |
    @case:702
    Examples:
      | subtotal |
      | 3037 |
    @case:703
    Examples:
      | subtotal |
      | 3074 |
    @case:704
    Examples:
      | subtotal |
      | 3111 |
    @case:705
    Examples:
      | subtotal |
      | 3148 |
    @case:706
    Examples:
      | subtotal |
      | 3185 |
    @case:707
    Examples:
      | subtotal |
      | 3222 |
    @case:708
    Examples:
      | subtotal |
      | 3259 |
    @case:709
    Examples:
      | subtotal |
      | 3296 |
    @case:710
    Examples:
      | subtotal |
      | 3333 |
    @case:711
    Examples:
      | subtotal |
      | 3370 |
    @case:712
    Examples:
      | subtotal |
      | 3407 |
    @case:713
    Examples:
      | subtotal |
      | 3444 |
    @case:714
    Examples:
      | subtotal |
      | 3481 |
    @case:715
    Examples:
      | subtotal |
      | 3518 |
    @case:716
    Examples:
      | subtotal |
      | 3555 |
    @case:717
    Examples:
      | subtotal |
      | 3592 |
    @case:718
    Examples:
      | subtotal |
      | 3629 |
    @case:719
    Examples:
      | subtotal |
      | 3666 |
    @case:720
    Examples:
      | subtotal |
      | 3703 |
    @case:721
    Examples:
      | subtotal |
      | 3740 |
    @case:722
    Examples:
      | subtotal |
      | 3777 |
    @case:723
    Examples:
      | subtotal |
      | 3814 |
    @case:724
    Examples:
      | subtotal |
      | 3851 |
    @case:725
    Examples:
      | subtotal |
      | 3888 |
    @case:726
    Examples:
      | subtotal |
      | 3925 |
    @case:727
    Examples:
      | subtotal |
      | 3962 |
    @case:728
    Examples:
      | subtotal |
      | 3999 |
    @case:729
    Examples:
      | subtotal |
      | 4036 |
    @case:730
    Examples:
      | subtotal |
      | 4073 |
    @case:731
    Examples:
      | subtotal |
      | 4110 |
    @case:732
    Examples:
      | subtotal |
      | 4147 |
    @case:733
    Examples:
      | subtotal |
      | 4184 |
    @case:734
    Examples:
      | subtotal |
      | 4221 |
    @case:735
    Examples:
      | subtotal |
      | 4258 |
    @case:736
    Examples:
      | subtotal |
      | 4295 |
    @case:737
    Examples:
      | subtotal |
      | 4332 |
    @case:738
    Examples:
      | subtotal |
      | 4369 |
    @case:739
    Examples:
      | subtotal |
      | 4406 |
    @case:740
    Examples:
      | subtotal |
      | 4443 |
    @case:741
    Examples:
      | subtotal |
      | 4480 |
    @case:742
    Examples:
      | subtotal |
      | 4517 |
    @case:743
    Examples:
      | subtotal |
      | 4554 |
    @case:744
    Examples:
      | subtotal |
      | 4591 |
    @case:745
    Examples:
      | subtotal |
      | 4628 |
    @case:746
    Examples:
      | subtotal |
      | 4665 |
    @case:747
    Examples:
      | subtotal |
      | 4702 |
    @case:748
    Examples:
      | subtotal |
      | 4739 |
    @case:749
    Examples:
      | subtotal |
      | 4776 |
    @case:750
    Examples:
      | subtotal |
      | 4813 |

  Scenario Outline: The TENOFF coupon below its minimum spend at subtotal <subtotal> is refused
    When the coupon "TENOFF" is applied to a subtotal of <subtotal>
    Then the response status is 400

    @case:751
    Examples:
      | subtotal |
      | 100 |
    @case:752
    Examples:
      | subtotal |
      | 140 |
    @case:753
    Examples:
      | subtotal |
      | 180 |
    @case:754
    Examples:
      | subtotal |
      | 220 |
    @case:755
    Examples:
      | subtotal |
      | 260 |
    @case:756
    Examples:
      | subtotal |
      | 300 |
    @case:757
    Examples:
      | subtotal |
      | 340 |
    @case:758
    Examples:
      | subtotal |
      | 380 |
    @case:759
    Examples:
      | subtotal |
      | 420 |
    @case:760
    Examples:
      | subtotal |
      | 460 |
    @case:761
    Examples:
      | subtotal |
      | 500 |
    @case:762
    Examples:
      | subtotal |
      | 540 |
    @case:763
    Examples:
      | subtotal |
      | 580 |
    @case:764
    Examples:
      | subtotal |
      | 620 |
    @case:765
    Examples:
      | subtotal |
      | 660 |
    @case:766
    Examples:
      | subtotal |
      | 700 |
    @case:767
    Examples:
      | subtotal |
      | 740 |
    @case:768
    Examples:
      | subtotal |
      | 780 |
    @case:769
    Examples:
      | subtotal |
      | 820 |
    @case:770
    Examples:
      | subtotal |
      | 860 |
    @case:771
    Examples:
      | subtotal |
      | 900 |
    @case:772
    Examples:
      | subtotal |
      | 940 |
    @case:773
    Examples:
      | subtotal |
      | 980 |
    @case:774
    Examples:
      | subtotal |
      | 1020 |
    @case:775
    Examples:
      | subtotal |
      | 1060 |
    @case:776
    Examples:
      | subtotal |
      | 1100 |
    @case:777
    Examples:
      | subtotal |
      | 1140 |
    @case:778
    Examples:
      | subtotal |
      | 1180 |
    @case:779
    Examples:
      | subtotal |
      | 1220 |
    @case:780
    Examples:
      | subtotal |
      | 1260 |
    @case:781
    Examples:
      | subtotal |
      | 1300 |
    @case:782
    Examples:
      | subtotal |
      | 1340 |
    @case:783
    Examples:
      | subtotal |
      | 1380 |
    @case:784
    Examples:
      | subtotal |
      | 1420 |
    @case:785
    Examples:
      | subtotal |
      | 1460 |
    @case:786
    Examples:
      | subtotal |
      | 1500 |
    @case:787
    Examples:
      | subtotal |
      | 1540 |
    @case:788
    Examples:
      | subtotal |
      | 1580 |
    @case:789
    Examples:
      | subtotal |
      | 1620 |
    @case:790
    Examples:
      | subtotal |
      | 1660 |
    @case:791
    Examples:
      | subtotal |
      | 1700 |
    @case:792
    Examples:
      | subtotal |
      | 1740 |
    @case:793
    Examples:
      | subtotal |
      | 1780 |
    @case:794
    Examples:
      | subtotal |
      | 1820 |
    @case:795
    Examples:
      | subtotal |
      | 1860 |
    @case:796
    Examples:
      | subtotal |
      | 1900 |
    @case:797
    Examples:
      | subtotal |
      | 1940 |
    @case:798
    Examples:
      | subtotal |
      | 1980 |
    @case:799
    Examples:
      | subtotal |
      | 2020 |
    @case:800
    Examples:
      | subtotal |
      | 2060 |
    @case:801
    Examples:
      | subtotal |
      | 2100 |
    @case:802
    Examples:
      | subtotal |
      | 2140 |
    @case:803
    Examples:
      | subtotal |
      | 2180 |
    @case:804
    Examples:
      | subtotal |
      | 2220 |
    @case:805
    Examples:
      | subtotal |
      | 2260 |
    @case:806
    Examples:
      | subtotal |
      | 2300 |
    @case:807
    Examples:
      | subtotal |
      | 2340 |
    @case:808
    Examples:
      | subtotal |
      | 2380 |
    @case:809
    Examples:
      | subtotal |
      | 2420 |
    @case:810
    Examples:
      | subtotal |
      | 2460 |
    @case:811
    Examples:
      | subtotal |
      | 2500 |
    @case:812
    Examples:
      | subtotal |
      | 2540 |
    @case:813
    Examples:
      | subtotal |
      | 2580 |
    @case:814
    Examples:
      | subtotal |
      | 2620 |
    @case:815
    Examples:
      | subtotal |
      | 2660 |
    @case:816
    Examples:
      | subtotal |
      | 2700 |
    @case:817
    Examples:
      | subtotal |
      | 2740 |
    @case:818
    Examples:
      | subtotal |
      | 2780 |
    @case:819
    Examples:
      | subtotal |
      | 2820 |
    @case:820
    Examples:
      | subtotal |
      | 2860 |
    @case:821
    Examples:
      | subtotal |
      | 2900 |
    @case:822
    Examples:
      | subtotal |
      | 2940 |
    @case:823
    Examples:
      | subtotal |
      | 2980 |
    @case:824
    Examples:
      | subtotal |
      | 3020 |
    @case:825
    Examples:
      | subtotal |
      | 3060 |
    @case:826
    Examples:
      | subtotal |
      | 3100 |
    @case:827
    Examples:
      | subtotal |
      | 3140 |
    @case:828
    Examples:
      | subtotal |
      | 3180 |
    @case:829
    Examples:
      | subtotal |
      | 3220 |
    @case:830
    Examples:
      | subtotal |
      | 3260 |
    @case:831
    Examples:
      | subtotal |
      | 3300 |
    @case:832
    Examples:
      | subtotal |
      | 3340 |
    @case:833
    Examples:
      | subtotal |
      | 3380 |
    @case:834
    Examples:
      | subtotal |
      | 3420 |
    @case:835
    Examples:
      | subtotal |
      | 3460 |
    @case:836
    Examples:
      | subtotal |
      | 3500 |
    @case:837
    Examples:
      | subtotal |
      | 3540 |
    @case:838
    Examples:
      | subtotal |
      | 3580 |
    @case:839
    Examples:
      | subtotal |
      | 3620 |
    @case:840
    Examples:
      | subtotal |
      | 3660 |
    @case:841
    Examples:
      | subtotal |
      | 3700 |
    @case:842
    Examples:
      | subtotal |
      | 3740 |
    @case:843
    Examples:
      | subtotal |
      | 3780 |
    @case:844
    Examples:
      | subtotal |
      | 3820 |
    @case:845
    Examples:
      | subtotal |
      | 3860 |
    @case:846
    Examples:
      | subtotal |
      | 3900 |
    @case:847
    Examples:
      | subtotal |
      | 3940 |
    @case:848
    Examples:
      | subtotal |
      | 3980 |
    @case:849
    Examples:
      | subtotal |
      | 4020 |
    @case:850
    Examples:
      | subtotal |
      | 4060 |
    @case:851
    Examples:
      | subtotal |
      | 4100 |
    @case:852
    Examples:
      | subtotal |
      | 4140 |
    @case:853
    Examples:
      | subtotal |
      | 4180 |
    @case:854
    Examples:
      | subtotal |
      | 4220 |
    @case:855
    Examples:
      | subtotal |
      | 4260 |
    @case:856
    Examples:
      | subtotal |
      | 4300 |
    @case:857
    Examples:
      | subtotal |
      | 4340 |
    @case:858
    Examples:
      | subtotal |
      | 4380 |
    @case:859
    Examples:
      | subtotal |
      | 4420 |
    @case:860
    Examples:
      | subtotal |
      | 4460 |
    @case:861
    Examples:
      | subtotal |
      | 4500 |
    @case:862
    Examples:
      | subtotal |
      | 4540 |
    @case:863
    Examples:
      | subtotal |
      | 4580 |
    @case:864
    Examples:
      | subtotal |
      | 4620 |
    @case:865
    Examples:
      | subtotal |
      | 4660 |
    @case:866
    Examples:
      | subtotal |
      | 4700 |
    @case:867
    Examples:
      | subtotal |
      | 4740 |
    @case:868
    Examples:
      | subtotal |
      | 4780 |
    @case:869
    Examples:
      | subtotal |
      | 4820 |
    @case:870
    Examples:
      | subtotal |
      | 4860 |

  Scenario Outline: Adding <qty> of product <pid> beyond its stock is refused
    Given a fresh cart
    When <qty> of product <pid> are added to the cart
    Then the response status is 409

    @case:871
    Examples:
      | qty | pid |
      | 51 | 1 |
    @case:872
    Examples:
      | qty | pid |
      | 21 | 2 |
    @case:873
    Examples:
      | qty | pid |
      | 9 | 3 |
    @case:874
    Examples:
      | qty | pid |
      | 16 | 4 |
    @case:875
    Examples:
      | qty | pid |
      | 6 | 5 |
    @case:876
    Examples:
      | qty | pid |
      | 31 | 7 |
    @case:877
    Examples:
      | qty | pid |
      | 13 | 8 |
    @case:878
    Examples:
      | qty | pid |
      | 52 | 1 |
    @case:879
    Examples:
      | qty | pid |
      | 22 | 2 |
    @case:880
    Examples:
      | qty | pid |
      | 10 | 3 |
    @case:881
    Examples:
      | qty | pid |
      | 17 | 4 |
    @case:882
    Examples:
      | qty | pid |
      | 7 | 5 |
    @case:883
    Examples:
      | qty | pid |
      | 32 | 7 |
    @case:884
    Examples:
      | qty | pid |
      | 14 | 8 |
    @case:885
    Examples:
      | qty | pid |
      | 53 | 1 |
    @case:886
    Examples:
      | qty | pid |
      | 23 | 2 |
    @case:887
    Examples:
      | qty | pid |
      | 11 | 3 |
    @case:888
    Examples:
      | qty | pid |
      | 18 | 4 |
    @case:889
    Examples:
      | qty | pid |
      | 8 | 5 |
    @case:890
    Examples:
      | qty | pid |
      | 33 | 7 |
    @case:891
    Examples:
      | qty | pid |
      | 15 | 8 |
    @case:892
    Examples:
      | qty | pid |
      | 54 | 1 |
    @case:893
    Examples:
      | qty | pid |
      | 24 | 2 |
    @case:894
    Examples:
      | qty | pid |
      | 12 | 3 |
    @case:895
    Examples:
      | qty | pid |
      | 19 | 4 |
    @case:896
    Examples:
      | qty | pid |
      | 9 | 5 |
    @case:897
    Examples:
      | qty | pid |
      | 34 | 7 |
    @case:898
    Examples:
      | qty | pid |
      | 16 | 8 |
    @case:899
    Examples:
      | qty | pid |
      | 55 | 1 |
    @case:900
    Examples:
      | qty | pid |
      | 25 | 2 |
    @case:901
    Examples:
      | qty | pid |
      | 13 | 3 |
    @case:902
    Examples:
      | qty | pid |
      | 20 | 4 |
    @case:903
    Examples:
      | qty | pid |
      | 10 | 5 |
    @case:904
    Examples:
      | qty | pid |
      | 35 | 7 |
    @case:905
    Examples:
      | qty | pid |
      | 17 | 8 |
    @case:906
    Examples:
      | qty | pid |
      | 56 | 1 |
    @case:907
    Examples:
      | qty | pid |
      | 26 | 2 |
    @case:908
    Examples:
      | qty | pid |
      | 14 | 3 |
    @case:909
    Examples:
      | qty | pid |
      | 21 | 4 |
    @case:910
    Examples:
      | qty | pid |
      | 11 | 5 |
    @case:911
    Examples:
      | qty | pid |
      | 36 | 7 |
    @case:912
    Examples:
      | qty | pid |
      | 18 | 8 |
    @case:913
    Examples:
      | qty | pid |
      | 57 | 1 |
    @case:914
    Examples:
      | qty | pid |
      | 27 | 2 |
    @case:915
    Examples:
      | qty | pid |
      | 15 | 3 |
    @case:916
    Examples:
      | qty | pid |
      | 22 | 4 |
    @case:917
    Examples:
      | qty | pid |
      | 12 | 5 |
    @case:918
    Examples:
      | qty | pid |
      | 37 | 7 |
    @case:919
    Examples:
      | qty | pid |
      | 19 | 8 |
    @case:920
    Examples:
      | qty | pid |
      | 58 | 1 |
    @case:921
    Examples:
      | qty | pid |
      | 28 | 2 |
    @case:922
    Examples:
      | qty | pid |
      | 16 | 3 |
    @case:923
    Examples:
      | qty | pid |
      | 23 | 4 |
    @case:924
    Examples:
      | qty | pid |
      | 13 | 5 |
    @case:925
    Examples:
      | qty | pid |
      | 38 | 7 |
    @case:926
    Examples:
      | qty | pid |
      | 20 | 8 |
    @case:927
    Examples:
      | qty | pid |
      | 59 | 1 |
    @case:928
    Examples:
      | qty | pid |
      | 29 | 2 |
    @case:929
    Examples:
      | qty | pid |
      | 17 | 3 |
    @case:930
    Examples:
      | qty | pid |
      | 24 | 4 |
    @case:931
    Examples:
      | qty | pid |
      | 14 | 5 |
    @case:932
    Examples:
      | qty | pid |
      | 39 | 7 |
    @case:933
    Examples:
      | qty | pid |
      | 21 | 8 |
    @case:934
    Examples:
      | qty | pid |
      | 60 | 1 |
    @case:935
    Examples:
      | qty | pid |
      | 30 | 2 |
    @case:936
    Examples:
      | qty | pid |
      | 18 | 3 |
    @case:937
    Examples:
      | qty | pid |
      | 25 | 4 |
    @case:938
    Examples:
      | qty | pid |
      | 15 | 5 |
    @case:939
    Examples:
      | qty | pid |
      | 40 | 7 |
    @case:940
    Examples:
      | qty | pid |
      | 22 | 8 |
    @case:941
    Examples:
      | qty | pid |
      | 61 | 1 |
    @case:942
    Examples:
      | qty | pid |
      | 31 | 2 |
    @case:943
    Examples:
      | qty | pid |
      | 19 | 3 |
    @case:944
    Examples:
      | qty | pid |
      | 26 | 4 |
    @case:945
    Examples:
      | qty | pid |
      | 16 | 5 |
    @case:946
    Examples:
      | qty | pid |
      | 41 | 7 |
    @case:947
    Examples:
      | qty | pid |
      | 23 | 8 |
    @case:948
    Examples:
      | qty | pid |
      | 62 | 1 |
    @case:949
    Examples:
      | qty | pid |
      | 32 | 2 |
    @case:950
    Examples:
      | qty | pid |
      | 20 | 3 |
    @case:951
    Examples:
      | qty | pid |
      | 27 | 4 |
    @case:952
    Examples:
      | qty | pid |
      | 17 | 5 |
    @case:953
    Examples:
      | qty | pid |
      | 42 | 7 |
    @case:954
    Examples:
      | qty | pid |
      | 24 | 8 |
    @case:955
    Examples:
      | qty | pid |
      | 63 | 1 |
    @case:956
    Examples:
      | qty | pid |
      | 33 | 2 |
    @case:957
    Examples:
      | qty | pid |
      | 21 | 3 |
    @case:958
    Examples:
      | qty | pid |
      | 28 | 4 |
    @case:959
    Examples:
      | qty | pid |
      | 18 | 5 |
    @case:960
    Examples:
      | qty | pid |
      | 43 | 7 |
    @case:961
    Examples:
      | qty | pid |
      | 25 | 8 |
    @case:962
    Examples:
      | qty | pid |
      | 64 | 1 |
    @case:963
    Examples:
      | qty | pid |
      | 34 | 2 |
    @case:964
    Examples:
      | qty | pid |
      | 22 | 3 |
    @case:965
    Examples:
      | qty | pid |
      | 29 | 4 |
    @case:966
    Examples:
      | qty | pid |
      | 19 | 5 |
    @case:967
    Examples:
      | qty | pid |
      | 44 | 7 |
    @case:968
    Examples:
      | qty | pid |
      | 26 | 8 |
    @case:969
    Examples:
      | qty | pid |
      | 65 | 1 |
    @case:970
    Examples:
      | qty | pid |
      | 35 | 2 |
    @case:971
    Examples:
      | qty | pid |
      | 23 | 3 |
    @case:972
    Examples:
      | qty | pid |
      | 30 | 4 |
    @case:973
    Examples:
      | qty | pid |
      | 20 | 5 |
    @case:974
    Examples:
      | qty | pid |
      | 45 | 7 |
    @case:975
    Examples:
      | qty | pid |
      | 27 | 8 |
    @case:976
    Examples:
      | qty | pid |
      | 66 | 1 |
    @case:977
    Examples:
      | qty | pid |
      | 36 | 2 |
    @case:978
    Examples:
      | qty | pid |
      | 24 | 3 |
    @case:979
    Examples:
      | qty | pid |
      | 31 | 4 |
    @case:980
    Examples:
      | qty | pid |
      | 21 | 5 |
    @case:981
    Examples:
      | qty | pid |
      | 46 | 7 |
    @case:982
    Examples:
      | qty | pid |
      | 28 | 8 |
    @case:983
    Examples:
      | qty | pid |
      | 67 | 1 |
    @case:984
    Examples:
      | qty | pid |
      | 37 | 2 |
    @case:985
    Examples:
      | qty | pid |
      | 25 | 3 |
    @case:986
    Examples:
      | qty | pid |
      | 32 | 4 |
    @case:987
    Examples:
      | qty | pid |
      | 22 | 5 |
    @case:988
    Examples:
      | qty | pid |
      | 47 | 7 |
    @case:989
    Examples:
      | qty | pid |
      | 29 | 8 |
    @case:990
    Examples:
      | qty | pid |
      | 68 | 1 |
    @case:991
    Examples:
      | qty | pid |
      | 38 | 2 |
    @case:992
    Examples:
      | qty | pid |
      | 26 | 3 |
    @case:993
    Examples:
      | qty | pid |
      | 33 | 4 |
    @case:994
    Examples:
      | qty | pid |
      | 23 | 5 |
    @case:995
    Examples:
      | qty | pid |
      | 48 | 7 |
    @case:996
    Examples:
      | qty | pid |
      | 30 | 8 |
    @case:997
    Examples:
      | qty | pid |
      | 69 | 1 |
    @case:998
    Examples:
      | qty | pid |
      | 39 | 2 |
    @case:999
    Examples:
      | qty | pid |
      | 27 | 3 |
    @case:1000
    Examples:
      | qty | pid |
      | 34 | 4 |
