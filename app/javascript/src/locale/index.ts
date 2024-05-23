// See app/javascript/components/helpers.tsx for previous implementation
import _ from 'lodash'
import translationsJp from './translations'

declare global { interface Window { locale: string } }
window.locale = window.gon.locale // Eg 'en' or 'jp'

export const t = (key: string, options: any = {}) => {
  const item = translationsJp[key]?.[window.locale]

  if (!item) {
    console.log('Translation not found:', key)
    return `Not Found: ${item}`
  } 

  // https://lodash.com/docs/4.17.15#template
  var template = _.template(item)
  return template(options)
}
