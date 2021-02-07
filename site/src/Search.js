import './App.css';

const Search = ({ activeTicker, setActiveTicker })  => {
    return (
        <label className="Search Search-text">
            Forecast for ticker
            <input className="Search-text" type="text" maxLength="7" value={activeTicker} onChange={setActiveTicker}/>
        </label>
    )
}

export default Search;
