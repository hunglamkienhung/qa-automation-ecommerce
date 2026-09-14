@module:06-minishop-security @be @api @minishop @security
Feature: The mini-shop authentication surface, probed like an attacker

  The mini-shop authenticates a customer by an opaque bearer token and gates the
  order endpoints on it. This tier probes those checks directly -- a forged or
  tampered token, a brute-force login, an attempt to learn whether an email is
  registered, a response that might leak a secret -- and confirms the right
  answers: 401 when the caller is not authenticated, a lock after repeated
  failures, one error shape whether or not the account exists, and never a
  password hash on the wire.

  Background:
    Given the store is open and the service is reachable

  # ---------------------------------------------------------------- forged / tampered tokens

  @case:156 @priority:high
  Scenario: A checkout with a forged token is refused
    Given a fresh cart
    And 1 of product 1 in the cart
    When checkout is posted with a forged token
    Then the response status is 401
    And the response is an error with code "unauthenticated"

  @case:157 @priority:high
  Scenario: A checkout with a tampered token is refused
    Given a registered buyer with a cart
    And the cart holds 1 of product 1
    When the buyer checks out with a token that extends their own
    Then the response status is 401

  @case:158 @priority:high
  Scenario: An order read with a forged token is refused
    Given a registered buyer with a cart
    And the cart holds 1 of product 1
    And the buyer checks out
    When the order is read with a forged token
    Then the response status is 401

  # ---------------------------------------------------------------- login: no enumeration, brute-force lockout

  @case:159 @priority:high
  Scenario: Login reveals nothing about whether an email exists
    Given a registered buyer
    When the buyer logs in with a wrong password
    Then the response is an error with code "bad_credentials"
    When a login is attempted for an unregistered email
    Then the response is an error with code "bad_credentials"

  @case:160 @priority:high
  Scenario: An account locks after too many failed logins
    Given a registered buyer
    When the buyer fails to log in 5 times
    And the buyer logs in with a wrong password
    Then the response status is 429
    And the response is an error with code "account_locked"

  @case:161 @priority:high
  Scenario: A locked account is refused even with the correct password
    Given a registered buyer
    When the buyer fails to log in 5 times
    And the buyer logs in with the right password
    Then the response status is 429
    And the response is an error with code "account_locked"

  @case:162 @priority:medium
  Scenario: A successful login clears the failed-login counter
    Given a registered buyer
    When the buyer fails to log in 4 times
    And the buyer logs in with the right password
    Then the response status is 200
    When the buyer logs in with a wrong password
    Then the response status is 401

  # ---------------------------------------------------------------- secret hygiene

  @case:163 @priority:high
  Scenario: Registration issues a token but never the password hash
    When a buyer registers
    Then the response status is 201
    And the response has a token
    And the response carries no password hash

  @case:164 @priority:high
  Scenario: Login never carries the password hash
    Given a registered buyer
    When the buyer logs in with the right password
    Then the response carries no password hash

  @case:165 @priority:medium
  Scenario: A product listing leaks no credential
    When GET /products?limit=100
    Then the response carries no token and no password hash
