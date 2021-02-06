import './App.css';
import About from "./About";

const Navbar = ({aboutModalOpen, setAboutModalOpen})  => {
    return ( 
        <div className="Navbar">
            <ul>
            <li><a href="#" className="Brand">GOMFD</a></li>
            <li><a href="#" className="MenuItem"><About aboutModalOpen={aboutModalOpen} setAboutModalOpen={setAboutModalOpen}/></a></li>
            {/* <li><a href="/market-movers" className="MenuItem">Market Movers</a></li> */}
            </ul>
        </div>
    )
}

export default Navbar;
