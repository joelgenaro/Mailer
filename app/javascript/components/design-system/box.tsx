import styled from 'styled-components'
import { space, SpaceProps, color, ColorProps, layout, LayoutProps, flexbox, FlexboxProps, border, BorderProps, typography, TypographyProps, boxShadow, BoxShadowProps, position, PositionProps } from 'styled-system'

export type BoxProps = SpaceProps & ColorProps & LayoutProps & FlexboxProps  & BorderProps & TypographyProps & BoxShadowProps & PositionProps

/**
 * The Box component serves as a wrapper component for most layout related needs
 */
const Box = styled.div<BoxProps>`
  ${space}
  ${color}
  ${layout}
  ${flexbox}
  ${border}
  ${typography}
  ${boxShadow}
  ${position}
`
export default Box