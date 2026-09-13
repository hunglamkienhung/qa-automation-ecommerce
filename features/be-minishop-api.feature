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
