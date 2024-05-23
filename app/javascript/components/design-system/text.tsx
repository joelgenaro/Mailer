import styled from 'styled-components'
import { typography, TypographyProps, space, SpaceProps, color, ColorProps, flexbox, FlexboxProps } from 'styled-system'
import css from '@styled-system/css'

type TextProps = TypographyProps & SpaceProps & ColorProps & FlexboxProps

const Text = styled('span')<TextProps>(
  color,
  typography,
  space,
  flexbox
)
export default Text