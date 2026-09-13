@module:01-minishop-db @be @db @minishop
Feature: The mini-shop store, read directly

  Both stacks open the SQLite file the mini-shop service writes and assert on
  its rows. The service is driven through its HTTP API to create state -- a
  checkout, a cart -- and the rows are then read straight from the file.

  Stock is shared global state, so the assertions are on DELTAS: note the stock
  before, act, and check what changed. That keeps every scenario independent of
  the order they run in, exactly the discipline the crypto tiers use with
  snapshot and revert.

  Background:
    Given the store is open and the service is reachable

  # ---------------------------------------------------------------- schema (throwaway db)

  @case:1 @priority:high
  Scenario: The store has the documented tables
    Then the store has tables categories, products, customers, carts, cart_items, coupons, orders, order_items, stock_movements

  @case:2 @priority:high
  Scenario: A product SKU is unique
    Given a throwaway database with the schema applied
    Then inserting two products with the same SKU fails on the second

  @case:3 @priority:high
  Scenario: Order lines reference a real order and a real product
    Given a throwaway database with the schema applied
    Then inserting an order_items row for a missing order fails a FOREIGN KEY
    And inserting an order_items row for a missing product fails a FOREIGN KEY

  @case:4 @priority:high
  Scenario: Amounts and quantities are bounded by CHECK
    Given a throwaway database with the schema applied
    Then inserting a product with negative price fails a CHECK
    And inserting a product with negative stock fails a CHECK
    And inserting a cart item with zero quantity fails a CHECK

  @case:5 @priority:medium
  Scenario: A stock movement is a real, non-zero change with a known reason
    Given a throwaway database with the schema applied
    Then inserting a stock movement with zero delta fails a CHECK
    And inserting a stock movement with reason "theft" fails a CHECK

  @case:6 @priority:medium
  Scenario: Seeding twice leaves the same rows
    Given a throwaway database with the schema and seed applied
    Then applying the seed again changes no row counts

  # ---------------------------------------------------------------- checkout writes the right rows

  @case:7 @priority:high
  Scenario: A checkout creates an order whose total equals the sum of its lines
    Given a registered buyer with a cart
    And the cart holds 2 of product 1 and 1 of product 2
    When the buyer checks out
    Then the order total equals the sum of its line amounts

  @case:8 @priority:high
  Scenario: Order lines capture the price at purchase
    Given a registered buyer with a cart
    And the cart holds 1 of product 4
    When the buyer checks out
    Then each order line price equals the product's price at purchase

  @case:9 @priority:high
  Scenario: Checkout decrements stock by the ordered quantity
    Given a registered buyer with a cart
    And the stock of product 1 is noted
    And the cart holds 3 of product 1
    When the buyer checks out
    Then the stock of product 1 fell by 3

  @case:10 @priority:high
  Scenario: Checkout records a matching stock movement
    Given a registered buyer with a cart
    And the cart holds 2 of product 2
    When the buyer checks out
    Then a stock movement of -2 for product 2 with reason "checkout" is linked to the order

  @case:11 @priority:high
  Scenario: The stock ledger balances against the running stock
    Given a registered buyer with a cart
    And the cart holds 1 of product 7
    When the buyer checks out
    Then the sum of movements for product 7 equals its current stock

  @case:12 @priority:high
  Scenario: An oversell is refused and leaves the store untouched
    Given a registered buyer with a cart
    And the stock of product 5 is noted
    And the order count is noted
    When the buyer tries to check out 999 of product 5
    Then the checkout is refused with code "insufficient_stock"
    And the stock of product 5 is unchanged
    And no new order was created

  @case:13 @priority:medium
  Scenario: An empty cart cannot be checked out
    Given a registered buyer with a cart
    And the order count is noted
    When the buyer checks out
    Then the checkout is refused with code "empty_cart"
    And no new order was created

  @case:14 @priority:medium
  Scenario: A checked-out cart is marked so
    Given a registered buyer with a cart
    And the cart holds 1 of product 1
    When the buyer checks out
    Then the cart row status is "checked_out"

  @case:15 @priority:medium
  Scenario: The order belongs to the buyer who placed it
    Given a registered buyer with a cart
    And the cart holds 1 of product 1
    When the buyer checks out
    Then the order's customer is the buyer

  @case:16 @priority:medium
  Scenario: One order line per distinct cart line
    Given a registered buyer with a cart
    And the cart holds 1 of product 1 and 2 of product 2 and 1 of product 7
    When the buyer checks out
    Then the order has 3 order lines

  @case:17 @priority:high
  Scenario: A percentage coupon is applied to the order
    Given a registered buyer with a cart
    And the cart holds 2 of product 2
    When the buyer checks out with coupon "SAVE10"
    Then the order discount is 10 percent of the subtotal
    And the order total is the subtotal minus the discount

  @case:18 @priority:high
  Scenario: A coupon redemption is counted exactly once
    Given a registered buyer with a cart
    And the redemption count of coupon "SAVE10" is noted
    And the cart holds 1 of product 2
    When the buyer checks out with coupon "SAVE10"
    Then the redemption count of coupon "SAVE10" grew by 1

  @case:19 @priority:high
  Scenario: A single-redemption coupon cannot be spent twice
    Given coupon "ONCE" has been fully redeemed
    And a registered buyer with a cart
    And the cart holds 1 of product 1
    When the buyer checks out with coupon "ONCE"
    Then the checkout is refused with code "coupon_exhausted"

  @case:20 @priority:high
  Scenario: A repeated checkout with the same idempotency key makes one order
    Given a registered buyer with a cart
    And the cart holds 1 of product 1
    And the order count is noted
    When the buyer checks out with idempotency key "abc-123"
    And the buyer checks out again with idempotency key "abc-123"
    Then exactly one new order was created
    And both checkouts returned the same order id

  @case:21 @priority:medium
  Scenario: No order line references a missing product
    Given a registered buyer with a cart
    And the cart holds 1 of product 1
    When the buyer checks out
    Then no order_items row references a product missing from products

  @case:22 @priority:medium
  Scenario: No order references a missing cart
    Then no orders row references a cart missing from carts

  @case:23 @priority:medium
  Scenario: The subtotal on the order equals the sum of quantity times price
    Given a registered buyer with a cart
    And the cart holds 2 of product 3 and 1 of product 8
    When the buyer checks out
    Then the order subtotal equals the sum of quantity times captured price

  @case:24 @priority:medium
  Scenario: The order total equals subtotal minus discount
    Given a registered buyer with a cart
    And the cart holds 1 of product 2
    When the buyer checks out with coupon "SAVE10"
    Then the order total equals the subtotal minus the discount on the row

  @case:25 @priority:high
  Scenario: Stock never runs negative across repeated checkouts
    Given a registered buyer with a cart
    When the buyer checks out 1 of product 5, 5 times
    Then the stock of product 5 is not negative

  # ---------------------------------------------------------------- parameterised over products

  Scenario Outline: Checkout of <sym> decrements its stock and records a movement
    Given a registered buyer with a cart
    And the stock of product <pid> is noted
    And the cart holds 2 of product <pid>
    When the buyer checks out
    Then the stock of product <pid> fell by 2
    And a stock movement of -2 for product <pid> with reason "checkout" is linked to the order

    @case:26
    Examples:
      | sym | pid |
      | tee | 1 |
    @case:27
    Examples:
      | sym | pid |
      | tote | 7 |
    @case:28
    Examples:
      | sym | pid |
      | backpack | 8 |

  # ---------------------------------------------------------------- cart and ledger

  @case:29 @priority:medium
  Scenario: Adding to a cart writes a cart line
    Given a registered buyer with a cart
    When the buyer adds 4 of product 1 to the cart
    Then a cart_items row holds 4 of product 1

  @case:30 @priority:medium
  Scenario: A seeded product's ledger balances from the start
    Then the seed movements for product 1 sum to a stock at or above its current stock
