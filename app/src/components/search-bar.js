import React from 'react'
import { connect } from 'redux-bundler-react'
import { pickBy } from 'lodash'

function SearchBar (props) {
  const {
    doUpdateInput,
    doUpdateQuery,
    input,
    searchFilter,
    queryObject } = props

  const filterBoxClasses = 'f6 link ba b--light-blue pv1 dib ph3 black bg-washed-blue magic-pointer'

  return (
      <form onSubmit={handleSubmit} className='flex flex-column mb0'>
      <label className='ttsc pb0 f6 mb2 mt2'>{searchFilter.replace('_',' ')}</label>
      <span className='flex flex-column'>
      <input name='ua-filter' type='text' value={input} onChange={handleInput} placeholder='regex pattern' className={filterBoxClasses}/>
      <input type='submit' value='Search'
        className='f6 link dim bn b--near-black pv1 dib ml0 ph3 black bg-light-blue magic-pointer flex items-center justify-center' />
     </span>
      </form>
      )

  function handleInput (e) {
    doUpdateInput(e.target.value)
  }
  function handleSubmit (e) {
    e.preventDefault()
    let filters = {
      useragents: queryObject.useragents,
      test_tags: queryObject.test_tags,
      tests: queryObject.tests,
      bucket: queryObject.bucket
    }
    filters[searchFilter] = e.target[0].value
    filters = pickBy(filters, (v,k) => v !== '' && v !== undefined)
    doUpdateQuery({...filters})
    doUpdateInput(undefined)
  }
}

export default connect(
  'doUpdateQuery',
  'selectQueryObject',
  SearchBar
)