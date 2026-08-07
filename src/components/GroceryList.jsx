import React from 'react'
import { useDispatch } from 'react-redux'
import { removeItemAsync } from '../store/grocerySlice'


const GroceryList = ({ items }) => {
    const dispatch = useDispatch();
    return (
        <ul className='grocery-list'>
            {items.length === 0 ? (
                <p className='empty'>No items in your grocery list</p>
            ) : (
                items.map((item) => (
                    <li key={item}>{item}
                        <button onClick={() => dispatch(removeItemAsync(item))}>Remove</button></li>
                ))
            )}
        </ul>
    )
}


export default GroceryList