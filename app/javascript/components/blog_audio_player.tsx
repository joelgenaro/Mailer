import React from 'react'
import { Player, Audio, DefaultUi } from '@vime/react'

import '@vime/core/themes/default.css'

/**
 * An Audio Player for the blog! 
 * For use with the 'embed_audio' shortcode.
 * 'url' prop is the url of the audio file to play (probably hosted on Contentful).
 * See also:
 * - app/views/shortcode_templates/embed_audio.html.erb
 * - https://vimejs.com/components/providers/audio
 */
const BlogAudioPlayer: React.FC<{ url: string }>  = (props) => {
  return (
    <Player
      theme="dark"
      style={{
         '--vm-player-theme': '#48AC98',
         '--vm-settings-max-height': '100%'
      } as any}
    >
      <Audio>
        <source 
          data-src={props.url}
          type="audio/mpeg"
        />
      </Audio>
      <DefaultUi />
    </Player>
  )
}

export default BlogAudioPlayer