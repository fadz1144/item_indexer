import React from "react";
import { BrowserRouter as Router, Route, Link } from "react-router-dom";
import Home from './pages/home';
import Preview from './pages/preview';
import Transform from './pages/transform';
import Inbound from './pages/inbound';
import Indexing from './pages/indexing';
import Topics from './pages/topics';
import './App.css';

function App() {
  return (
    <Router basename={`${process.env.PUBLIC_URL}/`}>
      <div className="App">
        <ul className="App-navigation">
          <li>
            <Link to="/preview">Preview</Link>
          </li>
          <li>
            <Link to="/inbound">Inbound</Link>
          </li>
          <li>
            <Link to="/transform">Transform</Link>
          </li>
          <li>
            <Link to="/indexing">Indexing</Link>
          </li>
        </ul>

        <hr />

        <Route exact path="/" component={Home} />
        <Route path="/preview" component={Preview} />
        <Route path="/inbound" component={Inbound} />
        <Route path="/transform" component={Transform} />
        <Route path="/indexing" component={Indexing} />
        <Route path="/topics" component={Topics} />
      </div>
    </Router>
  );
}

export default App;
