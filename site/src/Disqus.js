import { DiscussionEmbed } from 'disqus-react';

const Disqus = ({ ticker }) => {
    const dateString = new Date().toISOString().slice(0,10).replace(/-/g, '')

    return (
        <div className="Disqus">
            <DiscussionEmbed
                shortname='GOMFD'
                config={
                    {
                        url: `https://gomfd.com/?t=${ticker}&d=${dateString}`,
                        identifier: `${ticker}-${dateString}`,
                        title: ticker
                    }
                }
            />
        </div>
    );
  };

export default Disqus;
