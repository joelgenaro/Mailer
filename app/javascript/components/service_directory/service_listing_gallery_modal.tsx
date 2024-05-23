import React, {useEffect, useState} from 'react'
import GenericModal from '../generic_modal'
import Slider from "react-slick";
import "slick-carousel/slick/slick.scss";
import "slick-carousel/slick/slick-theme.scss";

declare global { interface Window { _openServiceListingGalleryModal:any } }

const ServiceListingGalleryModal: React.FC<{
    serviceListingImages: [],
    title: string,
}> = (props) => {
    const [open, setOpen] = useState(false);
    const [loading, setLoading] = useState(false);

    var settings = {
        dots: false,
        infinite: true,
        speed: 400,
        slidesToShow: 1,
        slidesToScroll: 1,
    };

    useEffect(()=>{
        window._openServiceListingGalleryModal = () => {
            setOpen(true)
        }
    },[])

    const closeSubscribeModal = () => {
        setOpen(false);
    }
    return (
        <>
            <GenericModal
                shouldCloseOnEsc={true}
                isOpen={open}
                onRequestClose={() => closeSubscribeModal()}
                customClass="service-listing-gallery-modal"
                buttonCustomClass="newsletter-subscription-button"
                bodyCustomClass="newsletter-subscription-body service-listing-gallery-body"
            >
                <div className="generic-modal__header">
                    <div className="generic-modal__heading">
                        {props.title}
                    </div>
                </div>
                <hr />
                <div className="service-listing-slides-container">
                    <Slider {...settings}>
                        {props.serviceListingImages? (props.serviceListingImages.map(image => (
                            <div>
                                <img src={image} alt={props.title}/>
                            </div>
                        ))) : {}}
                    </Slider>
                </div>
            </GenericModal>
        </>
    )
};
export default ServiceListingGalleryModal;
