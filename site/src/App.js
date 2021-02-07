import React, { useState, useEffect } from 'react';
import './App.css';
import Navbar from "./Navbar";
import Search from "./Search";
import PredictionFigure from "./PredictionFigure";
import Disqus from "./Disqus";
const querystring = require('querystring');

const App = () => {
  const urlTicker = querystring.parse(window.location.search.replace('?', ''))['t'];
  const [activeTicker, setActiveTicker] = useState(urlTicker || 'A');
  const [aboutModalOpen, setAboutModalOpen] = useState(false);

  useEffect(() => alert("Disclaimer: Information provided on this site is not financial advice.\n\nInvest at your own risk."), []);

  return (
    <div className="App">
      <Navbar aboutModalOpen={aboutModalOpen} setAboutModalOpen={setAboutModalOpen}/>
      <Search activeTicker={activeTicker} setActiveTicker={event => setActiveTicker(event.target.value.toUpperCase())}/>
      <PredictionFigure ticker={activeTicker} />
      <Disqus ticker={activeTicker} />
    </div>
  );
}

export default App;
