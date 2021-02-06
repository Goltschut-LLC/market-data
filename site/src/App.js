import React, { useState } from 'react';
import './App.css';
import Navbar from "./Navbar";
import Search from "./Search";
import PredictionFigure from "./PredictionFigure";

const App = () => {
  const [activeTicker, setActiveTicker] = useState('A');
  const [aboutModalOpen, setAboutModalOpen] = useState(false);

  return (
    <div className="App">
      <Navbar aboutModalOpen={aboutModalOpen} setAboutModalOpen={setAboutModalOpen}/>
      <Search activeTicker={activeTicker} setActiveTicker={event => setActiveTicker(event.target.value)}/>
      <PredictionFigure ticker={activeTicker} />
    </div>
  );
}

export default App;
