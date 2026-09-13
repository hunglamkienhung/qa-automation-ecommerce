@module:05-site-fe @fe @site
Feature: The live storefront, checked against the site's own API

  Playwright drives automationexercise.com. The figures on screen are compared
  with the same public API the BE branch reads, so the FE branch checks that the
  storefront and the API tell the same story. A page that never renders is
  Blocked, never Failed -- a live site being slow is not the site being wrong.

  Background:
    Given the products page is open

  @case:126 @priority:high
  Scenario: The storefront shows as many products as the API lists
    Then the number of products on screen equals the API product count

  @case:127 @priority:high
  Scenario: Every product on screen carries a name and a price
    Then every product card on screen has a name and a price

  @case:128 @priority:high
  Scenario: Every price on screen is in the "Rs. N" form
    Then every product price on screen matches the "Rs. N" format

  @case:129 @priority:medium
  Scenario: Every product name on screen is one the API knows
    Then every product name on screen is in the API product list

  @case:130 @priority:medium
  Scenario: The first product on screen matches the API's first product
    Then the first product on screen matches the first API product

  @case:131 @priority:medium
  Scenario: The storefront shows at least a dozen products
    Then the screen shows at least 12 products

  @case:132 @priority:low
  Scenario: No product card is missing its price
    Then no product card on screen is missing a price

  @case:133 @priority:low
  Scenario: No product card is missing its name
    Then no product card on screen is missing a name

  @case:134 @priority:medium
  Scenario: Product names on screen have no duplicates beyond the API's
    Then the screen's product names are drawn from the API without inventing any

  @case:135 @priority:medium
  Scenario: Every price on screen parses to a non-negative number
    Then every product price on screen parses to a non-negative number

  # ---------------------------------------------------------------- search

  @case:136 @priority:high
  Scenario: A search on screen returns a non-empty grid
    When the storefront is searched for "Top"
    Then the search grid on screen is non-empty

  @case:137 @priority:high
  Scenario: A search on screen returns no more products than the catalogue
    When the storefront is searched for "Dress"
    Then the search grid has no more products than the catalogue

  @case:138 @priority:medium
  Scenario: Every search result name is one the API knows
    When the storefront is searched for "Jeans"
    Then every search result name is in the API product list

  @case:139 @priority:medium
  Scenario: A search that matches nothing shows an empty grid, not an error
    When the storefront is searched for "zzqqxx-no-such-product"
    Then the search grid on screen is empty

  @case:140 @priority:low
  Scenario: Search prices are also in the "Rs. N" form
    When the storefront is searched for "Top"
    Then every product price on screen matches the "Rs. N" format

  Scenario Outline: Searching the storefront for "<term>" agrees with the API count
    When the storefront is searched for "<term>"
    Then the number of products on screen equals the API search count for "<term>"

    @case:141
    Examples:
      | term |
      | Top |
    @case:142
    Examples:
      | term |
      | Dress |
    @case:143
    Examples:
      | term |
      | Tshirt |

  @case:144 @priority:medium
  Scenario: A case-different search returns the same count on screen
    When the storefront is searched for "top"
    Then the number of products on screen equals the API search count for "top"

  # ---------------------------------------------------------------- brands

  @case:145 @priority:high
  Scenario: The brand rail lists the brands the API knows
    When the brand rail is read
    Then every brand on screen is in the API brand list

  @case:146 @priority:medium
  Scenario: The brand rail is non-empty
    When the brand rail is read
    Then the brand rail on screen is non-empty

  @case:147 @priority:low
  Scenario: The brand rail has no blank entries
    When the brand rail is read
    Then no brand on screen is blank

  # ---------------------------------------------------------------- consistency

  @case:148 @priority:medium
  Scenario: The product count on screen is stable across two loads
    Then the product count on screen is the same on a second load

  @case:149 @priority:low
  Scenario: Every product card price has a rupee symbol
    Then every product price on screen starts with "Rs."

  @case:150 @priority:medium
  Scenario: The screen's product names are a subset of the API's names
    Then every product name on screen is in the API product list

  @case:151 @priority:low
  Scenario: The grid shows unique product names in its first page
    Then the screen product names have no exact duplicates

  @case:152 @priority:medium
  Scenario: The most expensive on-screen price is a real API price
    Then the highest price on screen equals a price the API lists

  @case:153 @priority:low
  Scenario: The cheapest on-screen price is a real API price
    Then the lowest price on screen equals a price the API lists

  @case:154 @priority:medium
  Scenario: A search result count never exceeds the full grid count
    When the storefront is searched for "Shirt"
    Then the search grid has no more products than the catalogue

  @case:155 @priority:low
  Scenario: The products page has a heading
    Then the products page shows an "All Products" heading
