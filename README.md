# ReplaceAnimation [![codebeat](https://codebeat.co/badges/17b69dff-3ee4-498f-ab7d-0e96e49fd3cb)](https://codebeat.co/projects/github-com-fruitcoder-replaceanimation)
Implementation of Zee Young's Dribbble animation (https://dribbble.com/shots/2067564-Replace)

# Info
I really liked Zee Young's animation so I gave it a shot on iOS. Since I wanted to learn some things that I didn't have the chance to get my hands on lately, I tried using constraints to achieve the parallax effect, use CAShapeLayers for the trees and translate the content offset to the bending. Every button and view should be rendered on the device so I could lay them out in a .xib.

It's basically a `UICollectionView` with a sticky header flow layout (this one is based on https://github.com/Blackjacx/StickyHeaderFlowLayout) and all the parallax effects happen in `applyLayoutAttributes:`.

I added some jokes from "http://tambal.azurewebsites.net/joke/random" just so it's a little more interesting :)

## Refreshing
![alt tag](RefreshSuccess.gif) 

## Cancelling Refresh Animation
![alt tag](RefreshCancel.gif) 

## Scrolling
![alt tag](Scrolling.gif)

# Contribution
Any contribution is welcome. Just submit a pull request.

# Questions?
If you have any questions about why or how I solved certain things or the code doesn't make sense to you, just write me a message on Twitter.

# License
Available under MIT license. See the [LICENSE](https://github.com/fruitcoder/ReplaceAnimation/blob/master/LICENSE) for more info.
