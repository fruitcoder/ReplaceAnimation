# ReplaceAnimation
Implementation of Zee Young's Dribbble animation (https://dribbble.com/shots/2067564-Replace)

# Info
I really liked Zee Young's animation so I gave it a shot on iOS. Since I wanted to learn some things that I didn't have the chance to get my hands on lately, I tried using constaints to achieve the parallax effect, use CAShapeLayers for the trees and translate the content offset to the bending. Every button and view should be rendered on the device so I could lay them out in a .xib.

It's basically a `UICollectionView` with a sticky header flow layout (this one is based on https://github.com/Blackjacx/StickyHeaderFlowLayout) and all the parallax effects happen in `applyLayoutAttributes:`.

# License
Available under MIT license. See the [LICENSE](https://github.com/fruitcoder/ReplaceAnimation/blob/master/LICENSE) for more info.
