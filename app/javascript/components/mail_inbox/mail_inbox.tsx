// Dependencies
import 'react-tippy/dist/tippy.css'
import * as React from 'react'
import { ApolloProvider, gql } from '@apollo/client'
import { client } from '../../src/apollo'
import Loader from '../loader'
import MailInboxItem from '../mail_inbox_item'
import { t } from '../../src/locale'
import { DateTime } from 'luxon'

// Props
interface MailInboxProps {
  mailId: string,
  noResultsIllustrationSvg: string
}

// State
interface MailInboxState {
  items: Array<object>,
  currentItemId: string,
  filters: Array<object>,
  currentFilter: string,
  paginationCursor: string,
  paginationHasNextPage: boolean,
  isLoading: boolean,
  isLoadingMore: boolean,
  searchingFor: string,
  searchTimer: any
}

const POSTAL_MAILS = gql`
  query postalMails($search: String, $filter: String, $cursor: String) {
    postalMails(search: $search, filter: $filter, after: $cursor) {
      pageInfo {
        endCursor
        hasNextPage
      }
      edges {
        cursor
        node {
          id
          receivedOn
          receivedOnAbbv
          state
          stateHumanized
          notes
          previewThumbnail
          bill {
            paid
          }
        }
      }
    }
  }
`;

/**
 * Mail Inbox
 */
export default class MailInbox extends React.Component<MailInboxProps, MailInboxState> {
  /**
   * Initial State
   */
  readonly state = {
    items: [],
    currentItemId: null,
    filters: [
      {
        label: t('MailInbox.Mail'),
        items: [
          { key: null, label: t('MailInbox.All') },
          { key: 'unopened', label: t('MailInbox.Unopened') },
          { key: 'archived', label: t('MailInbox.Archived') }
        ]
      },
      {
        label: t('MailInbox.Bills'),
        items: [
          { key: 'unpaid_bills', label: t('MailInbox.Unpaid')},
          { key: 'paid_bills', label: t('MailInbox.Paid') }
        ]
      }
    ],
    currentFilter: null,
    paginationCursor: null,
    paginationHasNextPage: false,
    isLoading: true,
    isLoadingMore: false,
    searchingFor: null,
    searchTimer: null
  }

  /**
   * Component did mount
   */
  componentDidMount() {
    this.fetchItems()
  }

  /**
   * Fetches the postal_mails
   */
  async fetchItems() {
    this.setState({
      isLoading: true,
      currentItemId: null
    })

    let response = await client.query({ 
      query: POSTAL_MAILS,
      variables: {
        search: this.state.searchingFor,
        filter: this.state.currentFilter
      }
    })

    this.setState({
      items: this.formatPaginatedResponse(response.data.postalMails),
      currentItemId: this.props.mailId,
      paginationCursor: response.data.postalMails.pageInfo.endCursor,
      paginationHasNextPage: response.data.postalMails.pageInfo.hasNextPage,
      isLoading: false
    })
  }

  /**
   * Fetches the next page of postal_mails
   */
  async fetchNextPage() {
    this.setState({
      isLoadingMore: true
    })

    let response = await client.query({ 
      query: POSTAL_MAILS,
      variables: {
        search: this.state.searchingFor,
        filter: this.state.currentFilter,
        cursor: this.state.paginationCursor
      }
    })

    // Get the current items
    let newItems = this.state.items

    // Push the new items
    this.formatPaginatedResponse(response.data.postalMails).forEach((item) => {
      newItems.push(item)
    })

    this.setState({
      items: newItems,
      paginationCursor: response.data.postalMails.pageInfo.endCursor,
      paginationHasNextPage: response.data.postalMails.pageInfo.hasNextPage,
      isLoadingMore: false
    })
  }

  /**
   * Formats the paginated response into a more usable array of data
   */
  formatPaginatedResponse(items) {
    return items.edges.map(edge => edge.node)
  }

  /**
   * Handle when a list item is clicked
   */
  handleClickItem(id) {
    this.setState({ currentItemId: id })
  }

  /**
   * Handles when a filter is clicked
   */
  handleClickFilter(filter) {
    this.setState({ currentFilter: filter }, () => {
      this.fetchItems()
    })
  }

  /**
   * Handles searching after a time interval
   */
  handleSearch(value) {
    this.setState({
      searchingFor: value,
      searchTimer: clearTimeout(this.state.searchTimer)
    }, () => {
      this.setState({
        searchTimer: setTimeout(() => {
          this.fetchItems()
          this.setState({
            searchTimer: clearTimeout(this.state.searchTimer)
          })
        }, 500)
      })
    })
  }

  /**
   * Handles when the user scrolls down the list of postal mails
   */
  handleListScroll({ target }) {
    if (target.scrollHeight - target.scrollTop == target.clientHeight && this.state.paginationHasNextPage) {
      this.fetchNextPage()
    }
  }

  /**
   * Classes for a list item
   */
  classNameForListItem(item) {
    let classNames = ['mail-inbox__main__list__item', `mail-inbox__main__list__item--${item.state}`]
    if (item.bill) {
      classNames.push('mail-inbox__main__list__item--bill')
    }
    if (this.state.currentItemId && this.state.currentItemId == item.id) {
      classNames.push('mail-inbox__main__list__item--active')
    }
    return classNames.join(' ');
  }

  /**
   * Classes for a filter link
   */
  classNameForFilter(filter) {
    let classNames = ['mail-inbox__filters__link']
    if (this.state.currentFilter == filter) {
      classNames.push('mail-inbox__filters__link--active')
    }
    return classNames.join(' ');
  }

  /**
   * Renders the loading state
   */
  buildLoader() {
    return (
      <div className="mail-inbox__main__loading">
        <Loader isLoading={this.state.isLoading} />
      </div>
    )
  }

  /**
   * Renders all the filters
   */
  buildFilters() {
    return this.state.filters.map((section, index) => {
      return (
        <div key={index} className="mail-inbox__filters__section">
          <span className="mail-inbox__filters__lead">{section.label}</span>
          {this.buildFilterItems(section.items)}
        </div>
      )
    })
  }

  /**
   * Renders the filters for a section
   */
  buildFilterItems(items) {
    return items.map((filter, index) => {
      return (
        <div key={index} className="mail-inbox__filters__item">
          <a href="#" onClick={(e) => { e.preventDefault(); this.handleClickFilter(filter.key); }} className={this.classNameForFilter(filter.key)}>{filter.label}</a>
        </div>
      )
    })
  }

  /**
   * Renders the search
   */
  buildSearch() {
    return (
      <div className="mail-inbox__search">
        <div className="input-group">
          <input type="search" onChange={(e) => { this.handleSearch(e.target.value) }} className="form-control mail-inbox__search__input" placeholder={t("Search your inbox...")} />
        </div>
      </div>
    )
  }

  /**
   * Renders the list items
   */
  buildListItems(items) {
    return items.map((item, index) => {
      return (
        <div key={index} onClick={(e) => { this.handleClickItem(item.id) }} className={this.classNameForListItem(item)}>
          <div className="mail-inbox__main__list__item__details">
            <span className="mail-inbox__main__list__item__notes">{item.notes}</span>
            <span className="mail-inbox__main__list__item__state">{t(`MailInbox.PostalMail.StateHumanized.${item.stateHumanized}`)}</span>
            <span className="mail-inbox__main__list__item__received-on">{window.gon.locale === 'ja' ? DateTime.fromISO(item.receivedOn).toFormat('yyyy/MM/dd') : item.receivedOnAbbv}</span>
            <span className="mail-inbox__main__list__item__indicator"></span>
          </div>
        </div>
      )
    })
  }

  /**
   * Render
   */
  render() {
    return (
      <div className="mail-inbox">
        <div className="mail-inbox__filters">
          <div className="mail-inbox__filters__title">{t("Inbox")}</div>
          {this.buildFilters()}
        </div>
        <div className="mail-inbox__main">
          <div className="mail-inbox__main__left">
            <div className="mail-inbox__main__search">
              {this.buildSearch()}
            </div>
            <div className="mail-inbox__main__list" onScroll={(e) => { this.handleListScroll(e); }}>
              {this.state.isLoading ? this.buildLoader() : this.buildListItems(this.state.items)}
              {!this.state.isLoading && this.state.items.length == 0 &&
                <div className="mail-inbox__main__no-results">
                  <div className="mail-inbox__main__no-results__image" dangerouslySetInnerHTML={{__html: this.props.noResultsIllustrationSvg}} />
                  <div className="mail-inbox__main__no-results__text">{t(`MailInbox.PostalMail.Nothing to see here! This inbox is currently empty`)}</div>
                </div>
              }
              {this.state.isLoadingMore &&
                <div className="mail-inbox__main__loading-more">
                  <Loader isLoading={true} />
                </div>
              }
            </div>
          </div>
          <div className="mail-inbox__main__right">
            <div className="mail-inbox__main__item">
              {this.state.currentItemId &&
                <MailInboxItem id={this.state.currentItemId} />
              }
            </div>
          </div>
        </div>
      </div>
    );
  }
}
