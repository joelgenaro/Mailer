Stripe.api_key = ENV['STRIPE_SECRET_KEY']

STRIPE_PRICE_IDS = {
  :development => {
    # Assistant
    assistant_personal: 'price_1H0ns5HmYGHa1R8O9OOw3zz1',
    assistant_executive: 'price_1HC6U0HmYGHa1R8Ojxm1pcuA',
    assistant_business_basic: 'price_1HC6UFHmYGHa1R8Oc2WBVJ73',
    assistant_business_intermediate: 'price_1IJGzcHmYGHa1R8OPE2v73YT',
    assistant_business: 'price_1HC6UOHmYGHa1R8OJlRXvP5p',
    assistant_business_premium: 'price_1HC6UbHmYGHa1R8O3VGoNmqj',
    # Mail
    mail_personal: 'price_1GqHTzHmYGHa1R8Oo90iN0hW',
    mail_executive: 'price_1GqHTzHmYGHa1R8OixcurjJL',
    mail_sme: 'price_1GqHU0HmYGHa1R8OzOqMVETo',
    mail_enterprise: 'price_1GqHTzHmYGHa1R8Og2O5PJIf',
    # Receptionist
    receptionist_standard: 'price_1J7ao7HmYGHa1R8Og6bCIUTU'
  },
  :production => {
    # Assistant
    assistant_personal: 'price_1H38BLHmYGHa1R8ORDEp5lOb',
    assistant_executive: 'price_1HCMfHHmYGHa1R8OO2W4UJ4w',
    assistant_business_basic: 'price_1HCMfHHmYGHa1R8OYc54MhWX',
    assistant_business_intermediate: 'price_1IJGz4HmYGHa1R8OkxdjBsAI',
    assistant_business: 'price_1HCMfHHmYGHa1R8O80UXKxSP',
    assistant_business_premium: 'price_1HCMfHHmYGHa1R8Oy1UVQQ13',
    # Mail
    mail_personal: 'price_1Gs5EDHmYGHa1R8Oroth3aNk',
    mail_executive: 'price_1Gs5ECHmYGHa1R8OPgQzI5wS',
    mail_sme: 'price_1Gs5EDHmYGHa1R8OO06btj4t',
    mail_enterprise: 'price_1Gs5ECHmYGHa1R8OiYssj7c1',
    # Receptionst
    receptionist_standard: 'price_1J7amzHmYGHa1R8Ow14qqBuX',
  }
}.freeze

STRIPE_SKU_IDS = {
  :development => {
    three_more_hours: 'sku_HepUgTL29EH9x4',
    ten_more_hours: 'sku_Heulq4yPU9iouP'
  },
  :production => {
    three_more_hours: 'sku_HgORgRDAtNjwPi',
    ten_more_hours: 'sku_HgORokSMUa6PWr',
  }
}.freeze

STRIPE_CURRENCY_ISO = 'jpy'.freeze
STRIPE_ENVIRONMENT = (ENV['STRIPE_ENVIRONMENT'] || Rails.env).freeze
STRIPE_PRICES = STRIPE_PRICE_IDS[STRIPE_ENVIRONMENT.to_sym].freeze
STRIPE_SKUS = STRIPE_SKU_IDS[STRIPE_ENVIRONMENT.to_sym].freeze
