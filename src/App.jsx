import React, { useEffect } from 'react'
import { useSelector, useDispatch } from 'react-redux'
import { clearAllAsync, fetchItems, clearError } from './store/grocerySlice'
import GroceryList from './components/GroceryList'
import AddItemForm from './components/AddItemForm'
import FilterBar from './components/FilterBar'

const App = () => {
  const { items, filter, status, error } = useSelector((state) => state.groceries);
  const dispatch = useDispatch();

  useEffect(() => {
    dispatch(fetchItems());
  }, [dispatch])

  const filteredItems = filter ? items.filter(i => i.toLowerCase().includes(filter.toLowerCase())) : items;

  return (
    <main className='app-container'>
        <h1>Smart Grocery Manager</h1>
        {status === 'loading' && <p>Loading...</p>}
        {error && <div className='error'>Error: {error} <button onClick={() => dispatch(clearError())}>Dismiss</button></div>}
        <AddItemForm />
        <FilterBar />
        <GroceryList items={filteredItems} />
        <p className='count'>Total Items: {items.length} {filter && `(Filtered: ${filteredItems.length})`}</p>
        {items.length > 0 && (<button onClick={() => dispatch(clearAllAsync())}>Clear All</button>)}
    </main>
  )
}


export default App