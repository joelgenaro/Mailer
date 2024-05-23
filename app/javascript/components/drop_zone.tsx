import React,{useCallback} from 'react'
import {useDropzone} from 'react-dropzone'
export var newUploads =[]
export function DragDrop(props) {

    const onDrop = useCallback(acceptedFiles => {
        newUploads=acceptedFiles
      }, [])

    const {acceptedFiles, getRootProps, getInputProps} = useDropzone({onDrop,
        accept: {
            'image/jpeg': ['.jpeg', '.png', '.jpg', '.pdf']
        }
      });
    
    const files = acceptedFiles.map(file => (
      <li key={file.name}>
        {file.name} - {file.size} bytes
      </li>
    ));
  
    return (
      <section className="container">
        <aside>
          <ul>{files}</ul>
        </aside>
        <div {...getRootProps({className: 'dropzone'})}>
          <input {...getInputProps()} />
          <p>Drag and drop some files here, or click to select files</p>
        </div>
      </section>
    );
  }

