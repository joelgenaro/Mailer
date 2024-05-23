// Core ActiveAdmin style and js
import "../active_admin/styles/active_admin"
import "@activeadmin/activeadmin"

// ActiveAdmin Addons
import "activeadmin_addons" 

// Extensions
import "../active_admin/lib/extensions" 

// React components
var componentRequireContext = (require as any).context("../active_admin/components", true)
var ReactRailsUJS = require("react_ujs")
ReactRailsUJS.useContext(componentRequireContext)