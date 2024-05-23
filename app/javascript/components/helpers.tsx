/**
 * Returns a translation
 *
 * @param  {string} key
 * @param  {object} params
 * @return {string}
 */
export function t_old(key: string, params: object = {}) {
  let translations = (window as any).rn_I18n

  if ('count' in params) {
    return interpolate(pluralise(arrayDot(translations, key), params['count']), params)
  } else {
    return interpolate(arrayDot(translations, key), params)
  }
}

/**
 * Returns the appropriate pluralisation, based on the translation array and count value provided.
 *
 * @param  {object} translations
 * @param  {number} count
 * @return {string}
 */
export function pluralise(translations: object, count: number) {
  if (count == 0) {
    return translations['none']
  } else if (count > 1) {
    return translations['other']
  } else {
    return translations['one']
  }
}

/**
 * Replaces variables with real values in a translation string
 *
 * @param  {string} translation
 * @param  {object} params
 * @return {string}
 */
export function interpolate(translation: string, params: object) {
  let result = translation
  Object.keys(params).forEach((key) => {
    result = result.replace(`%{${key}}`, params[key])
  })
  return result;
}

/**
 * Returns a nested array value by key provided (in dot notation)
 *
 * @param  {object} object
 * @param  {string} key
 * @return {string}
 */
export function arrayDot(object: object, key: string) {
  let o: any = object
  let s: string = key.replace(/\[(\w+)\]/g, '.$1'); // convert indexes to properties
  s = s.replace(/^\./, ''); // strip a leading dot
  let a: Array<string> = s.split('.');
  for (let i = 0, n = a.length; i < n; ++i) {
    let k = a[i];
    if (k in o) {
      o = o[k];
    } else {
      return;
    }
  }
  return o;
}
