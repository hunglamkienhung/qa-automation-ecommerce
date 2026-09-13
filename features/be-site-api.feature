@module:03-site-api @be @api @site
Feature: The live site's public API, read-only

  HTTPS against automationexercise.com/api. No key, no browser. The API answers
  HTTP 200 for almost everything and carries the real outcome in a responseCode
  field in the body -- the assertions read that field.

  On a transport failure these scenarios report Blocked, never Failed: the site
  being unreachable is not the site being wrong.

  # ---------------------------------------------------------------- productsList

  @case:66 @priority:high
  Scenario: The product list answers 200 and is non-empty
    When the site product list is fetched
    Then the site response code is 200
    And the product list is non-empty

  @case:67 @priority:high
  Scenario: Every product has a unique id
    When the site product list is fetched
    Then no product id appears more than once

  @case:68 @priority:high
  Scenario: Every product price parses as a non-negative amount
    When the site product list is fetched
    Then every product price parses to a non-negative number

  @case:69 @priority:medium
  Scenario: Every product carries a name, brand and category
    When the site product list is fetched
    Then every product has a non-empty name, brand and category

  @case:70 @priority:low
  Scenario: The product list rejects POST as an unsupported method
    When the site product list is posted to
    Then the site response code is 405

  # ---------------------------------------------------------------- brandsList

  @case:71 @priority:high
  Scenario: The brand list answers 200 and is non-empty
    When the site brand list is fetched
    Then the site response code is 200
    And the brand list is non-empty

  @case:72 @priority:medium
  Scenario: Every brand has an id and a name
    When the site brand list is fetched
    Then every brand has an id and a non-empty name

  @case:73 @priority:low
  Scenario: The brand list rejects POST
    When the site brand list is posted to
    Then the site response code is 405

  # ---------------------------------------------------------------- searchProduct

  @priority:high
  Scenario Outline: Searching for "<term>" returns a non-empty subset of the catalogue
    # The site's search matches across name, category and brand, not the name
    # alone -- so the invariant is that every hit is a real catalogue product,
    # and there is at least one, not that the name contains the term.
    Given the full product list is fetched
    When the site is searched for "<term>"
    Then the site response code is 200
    And every returned product id is in the full product list
    And the search returns at least one product

    @case:74
    Examples:
      | term |
      | Top |
    @case:75
    Examples:
      | term |
      | Dress |
    @case:76
    Examples:
      | term |
      | Jeans |

  @case:77 @priority:medium
  Scenario: A search with no term is a bad request
    When the site is searched with no term
    Then the site response code is 400

  @case:78 @priority:low
  Scenario: A search that matches nothing returns an empty list, not an error
    When the site is searched for "zzqqxx-no-such-product"
    Then the site response code is 200
    And the returned product list is empty

  # ---------------------------------------------------------------- verifyLogin

  @case:79 @priority:high
  Scenario: verifyLogin without credentials is a bad request
    When login is verified with no email
    Then the site response code is 400

  @case:80 @priority:medium
  Scenario: verifyLogin for an unregistered email is not found
    When login is verified for an unregistered email
    Then the site response code is 404

  @case:81 @priority:low
  Scenario: verifyLogin rejects DELETE
    When login verification is sent as DELETE
    Then the site response code is 405

  # ---------------------------------------------------------------- getUserDetailByEmail

  @case:82 @priority:medium
  Scenario: An unknown user detail lookup is not found
    When the detail of an unregistered email is fetched
    Then the site response code is 404

  # ---------------------------------------------------------------- shape and consistency

  @case:83 @priority:medium
  Scenario: The product list and search draw from the same catalogue
    When the site product list is fetched
    And the site is searched for "Top"
    Then every searched product id is in the full product list

  @case:84 @priority:medium
  Scenario: Every product category names a user type
    When the site product list is fetched
    Then every product category has a category and a user type

  @case:85 @priority:low
  Scenario: The product list is stable across two reads
    When the site product list is fetched
    And the site product list is fetched again
    Then both reads return the same product ids

  @case:86 @priority:medium
  Scenario: Brand ids are unique
    When the site brand list is fetched
    Then no brand id appears more than once

  @case:87 @priority:low
  Scenario: Every product id is a positive integer
    When the site product list is fetched
    Then every product id is a positive integer

  @case:88 @priority:low
  Scenario: The response body is well-formed JSON with a numeric response code
    When the site product list is fetched
    Then the response body is a JSON object carrying a numeric response code

  @priority:medium
  Scenario Outline: The search for "<term>" is a subset of the catalogue by count
    When the site product list is fetched
    And the site is searched for "<term>"
    Then the search returns no more products than the full catalogue

    @case:89
    Examples:
      | term |
      | Top |
    @case:90
    Examples:
      | term |
      | Shirt |
    @case:91
    Examples:
      | term |
      | Cotton |

  @case:92 @priority:low
  Scenario: Prices are quoted in the documented "Rs. N" form
    When the site product list is fetched
    Then every product price matches the "Rs. N" format

  @case:93 @priority:low
  Scenario: Every brand name is trimmed and non-empty
    When the site brand list is fetched
    Then every brand name is non-empty when trimmed

  @case:94 @priority:medium
  Scenario: A case-insensitive search still matches
    When the site is searched for "top"
    And the site is searched for "TOP"
    Then both searches return the same product count

  @case:95 @priority:low
  Scenario: The catalogue has at least a dozen products
    When the site product list is fetched
    Then the product list has at least 12 products
