import { useState } from 'react';
import Modal from 'react-modal';
import './App.css';

const About = ({aboutModalOpen, setAboutModalOpen})  => {
    
    Modal.setAppElement(document.getElementById('root'));

    function openModal() {
      setAboutModalOpen(true);
    }
   
    function closeModal(){
      setAboutModalOpen(false);
    }

    return <div>
        <span onClick={openModal}>About</span>
        <Modal
            isOpen={aboutModalOpen}
            onRequestClose={closeModal}
            className="Modal-content"
        >
            <h1>GOMFD</h1>
            <h2>Goltschut Online Market Financial Data</h2>
            <br />
            <h3>Purpose</h3>
            <p>This site is intended to provide the public with access to basic financial forecasts. These forecasts utilize ARIMA regression, trained using daily price changes.</p>
            <h3>Disclaimer</h3>
            <p>Information provided on this site is not financial advice. Invest at your own risk.</p>
            <h3>Contact</h3>
            <p>GOMFD is built and maintained by Goltschut LLC. For more information, please visit us at <a href="https://goltschut.com">Goltschut</a></p>
            <button onClick={closeModal}>Close</button>
        </Modal>
    </div>

}

export default About;
