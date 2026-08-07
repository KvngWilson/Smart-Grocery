import React, { useState } from 'react'
import { useDispatch } from 'react-redux';
import { addItemAsync } from '../store/grocerySlice';

const AddItemForm = () => {
  const [item, setItem] = useState('');
  const dispatch = useDispatch();

  const handleSubmit = (e) => {
    e.preventDefault();
    if (item.trim()) {
      dispatch(addItemAsync(item));
      setItem('');
    }
  }
  return (
    <form id='form' className='form' onSubmit={handleSubmit}>
      <input id='input' type="text" placeholder='Enter grocery item...' value={item} onChange={(e) => setItem(e.target.value)} />
      <button id='submit' type='submit'>Add</button>
    </form>
  )
}

export default AddItemForm