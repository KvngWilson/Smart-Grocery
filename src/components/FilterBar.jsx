import React from 'react'
import { useDispatch } from 'react-redux'
import { setFilter } from '../store/grocerySlice'

const FilterBar = () => {
    const dispatch = useDispatch();
    return (
        <div className='filter-bar'>
            <input 
                id='filter' 
                type="text" 
                placeholder='Search items...' 
                onChange={(e) => dispatch(setFilter(e.target.value))} 
            />
        </div>
    )
}

export default FilterBar