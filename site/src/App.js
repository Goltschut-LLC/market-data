import React, { useState, useEffect } from 'react';
import './App.css';
import Navbar from "./Navbar";
import Search from "./Search";
import PredictionFigure from "./PredictionFigure";
import Disqus from "./Disqus";
import ReactGA from 'react-ga';
import AdSense from 'react-adsense';
const querystring = require('querystring');

ReactGA.initialize('UA-181672128-4');
ReactGA.pageview(window.location.pathname + window.location.search);

const DEFAULT_TICKER = 'QQQ'

const App = () => {
  const urlTicker = (querystring.parse(window.location.search.replace('?', ''))['t'] || DEFAULT_TICKER).toUpperCase();
  const [activeTicker, setActiveTicker] = useState(urlTicker);
  const [aboutModalOpen, setAboutModalOpen] = useState(false);

  useEffect(() => alert("Disclaimer: Information provided on this site is not financial advice.\n\nInvest at your own risk."), []);

  return (
    <div className="App">
      <Navbar aboutModalOpen={aboutModalOpen} setAboutModalOpen={setAboutModalOpen}/>
      <Search activeTicker={activeTicker} setActiveTicker={event => setActiveTicker(event.target.value.toUpperCase())}/>
      <PredictionFigure ticker={activeTicker} />
      <Disqus ticker={activeTicker} />
      <AdSense.Google
        client='ca-pub-9474581468737198'
        // slot='8XXXXX1'
      />
    </div>
  );
}

export default App;
