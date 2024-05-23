import ahoy from 'ahoy.js'

interface AnalyticsTrackConfiguration { 
  // Google Global Site Tag
  gtagSendto?: string, // The conversion action id on adwords to send to, eg 'AW-710898837/NxXgCMWi4PcBEJXp_dIC', use value from adwordsActionIds
  gtagValue?: number, // The value of the conversion (eg subscription price) as float (eg 10000.0), should be used with 'gtagCurrency'
  gtagCurrency?: 'JPY', // Currency of the transaction (should be used with 'gtagValue'), likely always 'JPY'
  // Facebook Pixel
  fbqValue?: number, // The value of the conversion (eg subscription price) as float (eg 10000.0), should be used with 'fbqCurrency'
  fbqCurrency?: 'JPY', // Currency of the transaction (should be used with 'fbqValue'), likely always 'JPY'
}

/**
 * Analytics handling
 * 
 * Use as a window variable in other tsx or erb files:
 * window.Analytics.track('Helloed The World)
 * 
 * We like Proper Case for events and snake_case for properties.
 * Events should be in past tense eg "Viewed Product". 
 * See: https://segment.com/academy/collecting-data/naming-conventions-for-clean-data/
 * 
 * gtag and fbq should be setup in the layout's <head> section
 * 
 * References:
 * - Ahoy: https://github.com/ankane/ahoy.js
 * - Google Global Site Tag: https://support.google.com/google-ads/answer/7548399
 * - Facebook Tracking Pixel: https://developers.facebook.com/docs/facebook-pixel/
 */
export default class Analytics {
  debug = true

  /**
   * Track an event
   * @param name Name of event
   * @param properties properties
   * @param configuration Configuration of the event, eg if to send to Adwords or to only certain channels
   */
  track(name: string, properties?: any, configuration?: AnalyticsTrackConfiguration) {
    // Debug
    if (this.debug) {
      console.log(`[Analytics.track] ${name}`, properties, configuration)
    }

    // Ahoy 
    ahoy.track(name, properties)

    // Google Global Site Tag (Google Analytics & Google Adwords)
    if (window.gtag) { // Ensure is loaded (might not be if no env var set in head)
      // Make properties for gtag, only overriding values if we have them 
      let gtagProperties = properties || {}
      if (configuration?.gtagSendto) gtagProperties['send_to'] = configuration.gtagSendto
      if (configuration?.gtagValue) gtagProperties['value'] = configuration.gtagValue
      if (configuration?.gtagCurrency) gtagProperties['currency'] = configuration.gtagCurrency

      window.gtag('event', name, gtagProperties)
    }

    // Facebook
    if (window.fbq) { // Ensure is loaded (might not be if no env var set in head)
      // Make properities for facebook, only overriding values if we have them 
      // Facebook's predefined properties https://developers.facebook.com/docs/facebook-pixel/implementation/conversion-tracking#object-properites
      let fbqProperties = properties || {}
      if (configuration.fbqValue) fbqProperties['value'] = configuration.fbqValue
      if (configuration.fbqCurrency) fbqProperties['current'] = configuration.fbqCurrency

      window.fbq('track', name, fbqProperties)
    }
  }

  /**
   * Adwords Conversion Action Ids
   * Get the ids/snippets from: https://ads.google.com/aw/conversions per conversion to track
   */
  adwordsActionIds = {
    clickedSignUpButton: 'AW-710898837/NxXgCMWi4PcBEJXp_dIC', // 'Clicked Sign Up Button' conversion action on Adwords
    visitedCheckout: 'AW-710898837/NnVNCMG84PcBEJXp_dIC', // "Visited Checkout" conversion action on Adwords
    consultationRequested: 'AW-710898837/nia0CNq5y_cBEJXp_dIC', // 'Consultation Requested' conversion action on Adwords
    viewedPricing: 'AW-710898837/A5dICL_MhvMBEJXp_dIC', // 'Viewed Pricing' conversion action on Adwords
    subscriptionCreated:  'AW-710898837/tJs3CJD-yvcBEJXp_dIC', // 'Subscription Created' conversion action on Adwords
  }
}