# Checkout with discount rules

A small Rails app for the Matic test assignment: a grocery checkout that scans
product codes, applies the current offers and shows the receipt. The pricing
logic is plain Ruby; Rails serves one page on top of it, an internal tool to
validate the current offers. Product codes live in the URL
(`/checkout?items=FR,SR,FR`), so every state of the page is a link and there is
no session and no JavaScript.

## Run it

Ruby version is pinned in `.ruby-version` (3.4.12).

```sh
bundle install
bundle exec rspec
bin/rails server
```

Then open <http://localhost:3000>.

## Project map

```
app/concepts/checkout.rb                      Checkout: scan, total, receipt (the interface from the assignment)
app/concepts/checkout/
  catalog.rb, product.rb                      products and prices
  item.rb, discount.rb, receipt.rb            receipt data: lines, discounts, subtotal, total
  offers.rb                                   the current offers, in one place
  rules/buy_n_get_m_free.rb                   "buy N, get M free"
  rules/bulk_price.rb                         "N or more for a lower unit price"
  operation/build_receipt.rb                  text with codes -> receipt, or the list of unknown codes
app/controllers/checkouts_controller.rb       reads params, calls the operation, renders
app/helpers/checkouts_helper.rb               product and offer labels from translations
app/views/checkouts/                          the page: show + partials for scanning, offers, receipt
config/locales/en.yml                         every label the page shows, product names included
spec/                                         mirrors app/: domain, rules, operation, request specs
```

`app/concepts/checkout/` is a feature folder: the domain and the one operation
that drives it sit together, and nothing in it knows about Rails, HTTP or
translations.

## The interface from the assignment

```ruby
# bin/rails console
co = Checkout.new(*Checkout::Offers.current)
co.scan('FR')
co.scan('FR')
co.total.to_s('F')  # => "3.11"
```

## Adding an offer

A rule is any object with three methods:

```ruby
rule.name           # => :bulk_price                     translation key of the label
rule.params         # => { code: 'SR', min_quantity: 3, price: BigDecimal('4.50') }
rule.apply(items)   # => [Checkout::Discount, ...] or []  items are the basket lines
```

- Another offer with an existing mechanic: add a line to
  [`offers.rb`](app/concepts/checkout/offers.rb).
- A new mechanic: add a class to [`rules/`](app/concepts/checkout/rules) and a
  label to `en.yml`. `Checkout` does not change; the spec
  [`accepts a new rule without changes`](spec/concepts/checkout_spec.rb)
  does exactly this with a rule defined inside the test.

## Assumptions

- **Discounts add up.** Rules are independent, so two rules on the same product
  both apply. Passing the same rule twice applies it twice; that is a
  configuration error, not something `Checkout` guards against.
- **Unknown codes are an error.** `Checkout#scan` raises
  `Checkout::UnknownProduct`; the page lists the unknown codes.
- **Money is `BigDecimal`**, created from strings and formatted only in the
  view. The assignment's examples already drift in floats depending on the
  order of additions.
- **Rounding belongs to the rule.** The current rules multiply by whole
  quantities and are exact; a rule that can produce fractions of a cent rounds
  its own discount, as the 10%-off rule in the specs does.

## Deliberately not done

- Offer validity dates, rule priorities, offers in a database: nothing in the
  assignment needs them.
- JavaScript: the page is stateless and the server does all the work.
- A base class for operations: there is one operation.
- The app was generated with `rails new --minimal --skip-active-record` and the
  generated files that do nothing for this task were removed.
