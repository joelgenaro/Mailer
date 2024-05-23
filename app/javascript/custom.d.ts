/**
 * Custom Typescript Types
 */

// Assets
// Note: may have to restart webpacker after adding an asset
declare module '*.jpg';
declare module '*.jpeg';
declare module '*.png';
declare module '*.gif';
declare module '*.m4a';

// SVG
// From: https://stackoverflow.com/a/45887328
// For use with React SVG Loader: https://github.com/rails/webpacker/blob/master/docs/webpack.md#react-svg-loader
declare module "*.svg" {
  const content: React.FunctionComponent<React.SVGAttributes<SVGElement>>;
  export default content;
}