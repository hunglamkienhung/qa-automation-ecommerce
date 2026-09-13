@module:04-minishop-fe @fe @minishop
Feature: The mini-shop storefront, checked against its own data

  Playwright drives the mini-shop HTML pages. The figures on screen are compared
  with the rows behind them -- read through the DB the FE never touches directly
  -- so the FE branch checks the same invariants the BE branch does, one layer
  further out. A page that never loads is Blocked, never Failed.

  Background:
    Given the store is open and the service is reachable
    And the storefront is open

  @case:96 @priority:high
  Scenario: The catalogue lists exactly the active products
    Then the catalogue lists the active products, once each

  @case:97 @priority:high
  Scenario: Every catalogue price on screen matches its row
    Then every catalogue price on screen equals the product row

  @case:98 @priority:high
  Scenario: The out-of-stock product is labelled out of stock
    Then product 6 is shown out of stock

  @case:99 @priority:medium
  Scenario: In-stock products are labelled in stock
    Then product 1 is shown in stock

  @case:100 @priority:medium
  Scenario: The inactive product does not appear on the catalogue
    Then the catalogue does not list product 9

  @case:101 @priority:high
  Scenario: A product page shows the name, price and SKU from the row
    When the product page for 4 is opened
    Then the product page name, price and SKU equal row 4

  @case:102 @priority:medium
  Scenario: A product page shows the stock level from the row
    When the product page for 2 is opened
    Then the product page stock equals row 2

  @case:103 @priority:medium
  Scenario: An unknown product page is not found
    When the product page for 999 is opened
    Then the product page reports not found

  @case:104 @priority:medium
  Scenario: The out-of-stock product page says so
    When the product page for 6 is opened
    Then the product page 6 is shown out of stock

  @case:105 @priority:high
  Scenario: An order page shows the total the order was placed at
    Given a placed order of 2 of product 1 and 1 of product 2
    When the order page is opened
    Then the order page total equals the stored order total

  @case:106 @priority:medium
  Scenario: An order page shows the order id and a placed status
    Given a placed order of 1 of product 1
    When the order page is opened
    Then the order page shows the order id and status "placed"

  @case:107 @priority:medium
  Scenario: The catalogue price format is a dollar amount
    Then every catalogue price is shown as a dollar amount

  @case:108 @priority:low
  Scenario: The catalogue is not empty
    Then the catalogue shows at least one product

  @case:109 @priority:medium
  Scenario: Each catalogue name matches its product row
    Then every catalogue name on screen equals the product row

  @case:110 @priority:low
  Scenario: An unknown order page is not found
    When the order page for 999999 is opened
    Then the order page reports not found

  Scenario Outline: The product page for <pid> matches its row
    When the product page for <pid> is opened
    Then the product page name, price and SKU equal row <pid>

    @case:111
    Examples:
      | pid |
      | 1 |
    @case:112
    Examples:
      | pid |
      | 5 |
    @case:113
    Examples:
      | pid |
      | 7 |

  Scenario Outline: <label> product's price on the catalogue equals its row
    Then the catalogue price for product <pid> equals its row

    @case:114
    Examples:
      | label | pid |
      | tee | 1 |
    @case:115
    Examples:
      | label | pid |
      | boot | 5 |
    @case:116
    Examples:
      | label | pid |
      | backpack | 8 |

  @case:117 @priority:medium
  Scenario: The catalogue product count equals the active count in the API
    Then the catalogue count equals the API active product count

  @case:118 @priority:low
  Scenario: The product page price format is a dollar amount
    When the product page for 3 is opened
    Then the product page price is shown as a dollar amount

  @case:119 @priority:low
  Scenario: A product page name is non-empty
    When the product page for 8 is opened
    Then the product page name is non-empty

  @case:120 @priority:medium
  Scenario: The order page total is a dollar amount
    Given a placed order of 1 of product 4
    When the order page is opened
    Then the order page total is shown as a dollar amount

  @case:121 @priority:low
  Scenario: The catalogue links each product to its own page
    Then each catalogue row links to its product page

  @case:122 @priority:medium
  Scenario: A discounted order page shows the discounted total
    Given a placed order of 2 of product 2 with coupon "SAVE10"
    When the order page is opened
    Then the order page total equals the stored order total

  @case:123 @priority:low
  Scenario: Every catalogue stock label is one of two known values
    Then every catalogue stock label is in stock or out of stock

  @case:124 @priority:medium
  Scenario: The product page SKU matches its row exactly
    When the product page for 7 is opened
    Then the product page SKU equals row 7

  @case:125 @priority:low
  Scenario: The catalogue product ids are unique on screen
    Then no catalogue product id appears twice
