import Foundation
import UIKit
import Display
import AsyncDisplayKit
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import ItemListUI
import PresentationDataUtils
import AppBundle
import ComponentFlow
import SliderComponent

// MARK: - Шапка раздела: логотип, название, версия (без карточки, как в Nextgram)

final class MGBrandItem: ListViewItem, ItemListItem {
    let theme: PresentationTheme
    let version: String
    let sectionId: ItemListSectionId

    init(theme: PresentationTheme, version: String, sectionId: ItemListSectionId) {
        self.theme = theme
        self.version = version
        self.sectionId = sectionId
    }

    func nodeConfiguredForParams(async: @escaping (@escaping () -> Void) -> Void, params: ListViewItemLayoutParams, synchronousLoads: Bool, neighbors: ListViewItemNeighbors, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, (ListViewItemApply) -> Void)) -> Void) {
        async {
            let node = MGBrandItemNode()
            let (layout, apply) = node.asyncLayout()(self, params)

            node.contentSize = layout.contentSize
            node.insets = layout.insets

            Queue.mainQueue().async {
                completion(node, {
                    return (nil, { _ in apply() })
                })
            }
        }
    }

    func updateNode(async: @escaping (@escaping () -> Void) -> Void, node: @escaping () -> ListViewItemNode, params: ListViewItemLayoutParams, neighbors: ListViewItemNeighbors, animation: ListViewItemUpdateAnimation, completion: @escaping (ListViewItemNodeLayout, @escaping (ListViewItemApply) -> Void) -> Void) {
        Queue.mainQueue().async {
            if let nodeValue = node() as? MGBrandItemNode {
                let makeLayout = nodeValue.asyncLayout()

                async {
                    let (layout, apply) = makeLayout(self, params)
                    Queue.mainQueue().async {
                        completion(layout, { _ in
                            apply()
                        })
                    }
                }
            }
        }
    }
}

final class MGBrandItemNode: ListViewItemNode {
    private let logoNode: ASImageNode
    private let titleNode: ImmediateTextNode
    private let versionNode: ImmediateTextNode

    init() {
        self.logoNode = ASImageNode()
        self.logoNode.displaysAsynchronously = false
        self.titleNode = ImmediateTextNode()
        self.versionNode = ImmediateTextNode()

        super.init(layerBacked: false)

        self.addSubnode(self.logoNode)
        self.addSubnode(self.titleNode)
        self.addSubnode(self.versionNode)
    }

    func asyncLayout() -> (_ item: MGBrandItem, _ params: ListViewItemLayoutParams) -> (ListViewItemNodeLayout, () -> Void) {
        return { item, params in
            let contentSize = CGSize(width: params.width, height: 226.0)
            let layout = ListViewItemNodeLayout(contentSize: contentSize, insets: UIEdgeInsets())

            return (layout, { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                let logoSide: CGFloat = 96.0
                if let image = UIImage(bundleImageName: "Components/MattGramMark") {
                    strongSelf.logoNode.image = generateTintedImage(image: image, color: item.theme.list.itemPrimaryTextColor)
                }
                strongSelf.logoNode.frame = CGRect(origin: CGPoint(x: floor((params.width - logoSide) / 2.0), y: 20.0), size: CGSize(width: logoSide, height: logoSide))

                strongSelf.titleNode.attributedText = NSAttributedString(string: "MattGram", font: Font.heavy(30.0), textColor: item.theme.list.itemPrimaryTextColor)
                let titleSize = strongSelf.titleNode.updateLayout(CGSize(width: params.width - 32.0, height: 60.0))
                strongSelf.titleNode.frame = CGRect(origin: CGPoint(x: floor((params.width - titleSize.width) / 2.0), y: 134.0), size: titleSize)

                strongSelf.versionNode.attributedText = NSAttributedString(string: item.version, font: Font.semibold(17.0), textColor: item.theme.list.itemSecondaryTextColor)
                let versionSize = strongSelf.versionNode.updateLayout(CGSize(width: params.width - 32.0, height: 40.0))
                strongSelf.versionNode.frame = CGRect(origin: CGPoint(x: floor((params.width - versionSize.width) / 2.0), y: 174.0), size: versionSize)
            })
        }
    }
}

// MARK: - Ползунок со значением (по образцу стокового EnergyUsageBatteryLevelItem)

final class MGSliderItem: ListViewItem, ItemListItem {
    let theme: PresentationTheme
    let title: String
    let valueText: String
    let fraction: CGFloat
    let sectionId: ItemListSectionId
    let updated: (CGFloat) -> Void

    init(theme: PresentationTheme, title: String, valueText: String, fraction: CGFloat, sectionId: ItemListSectionId, updated: @escaping (CGFloat) -> Void) {
        self.theme = theme
        self.title = title
        self.valueText = valueText
        self.fraction = fraction
        self.sectionId = sectionId
        self.updated = updated
    }

    func nodeConfiguredForParams(async: @escaping (@escaping () -> Void) -> Void, params: ListViewItemLayoutParams, synchronousLoads: Bool, neighbors: ListViewItemNeighbors, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, (ListViewItemApply) -> Void)) -> Void) {
        async {
            let node = MGSliderItemNode()
            let (layout, apply) = node.asyncLayout()(self, params, itemListNeighbors(item: self, topFacet: neighbors.previous?.base(ItemListNeighborFacet.self), bottomFacet: neighbors.next?.base(ItemListNeighborFacet.self)))

            node.contentSize = layout.contentSize
            node.insets = layout.insets

            Queue.mainQueue().async {
                completion(node, {
                    return (nil, { _ in apply() })
                })
            }
        }
    }

    func updateNode(async: @escaping (@escaping () -> Void) -> Void, node: @escaping () -> ListViewItemNode, params: ListViewItemLayoutParams, neighbors: ListViewItemNeighbors, animation: ListViewItemUpdateAnimation, completion: @escaping (ListViewItemNodeLayout, @escaping (ListViewItemApply) -> Void) -> Void) {
        Queue.mainQueue().async {
            if let nodeValue = node() as? MGSliderItemNode {
                let makeLayout = nodeValue.asyncLayout()

                async {
                    let (layout, apply) = makeLayout(self, params, itemListNeighbors(item: self, topFacet: neighbors.previous?.base(ItemListNeighborFacet.self), bottomFacet: neighbors.next?.base(ItemListNeighborFacet.self)))
                    Queue.mainQueue().async {
                        completion(layout, { _ in
                            apply()
                        })
                    }
                }
            }
        }
    }
}

final class MGSliderItemNode: ListViewItemNode {
    private let backgroundNode: ASDisplayNode
    private let topStripeNode: ASDisplayNode
    private let bottomStripeNode: ASDisplayNode
    private let maskNode: ASImageNode

    private let titleNode: ImmediateTextNode
    private let valueNode: ImmediateTextNode
    private let slider = ComponentView<Empty>()

    private var item: MGSliderItem?

    init() {
        self.backgroundNode = ASDisplayNode()
        self.backgroundNode.isLayerBacked = true

        self.topStripeNode = ASDisplayNode()
        self.topStripeNode.isLayerBacked = true

        self.bottomStripeNode = ASDisplayNode()
        self.bottomStripeNode.isLayerBacked = true

        self.maskNode = ASImageNode()

        self.titleNode = ImmediateTextNode()
        self.valueNode = ImmediateTextNode()

        super.init(layerBacked: false)

        self.addSubnode(self.titleNode)
        self.addSubnode(self.valueNode)
    }

    func asyncLayout() -> (_ item: MGSliderItem, _ params: ListViewItemLayoutParams, _ neighbors: ItemListNeighbors) -> (ListViewItemNodeLayout, () -> Void) {
        return { item, params, neighbors in
            let separatorHeight = UIScreenPixel
            let separatorRightInset: CGFloat = 16.0
            let verticalInset: CGFloat = 4.0

            let contentSize = CGSize(width: params.width, height: 88.0 + verticalInset * 2.0)
            let insets = itemListNeighborsGroupedInsets(neighbors, params)

            let layout = ListViewItemNodeLayout(contentSize: contentSize, insets: insets)
            let layoutSize = layout.size

            return (layout, { [weak self] in
                if let strongSelf = self {
                    strongSelf.item = item

                    strongSelf.backgroundNode.backgroundColor = item.theme.list.itemBlocksBackgroundColor
                    strongSelf.topStripeNode.backgroundColor = item.theme.list.itemBlocksSeparatorColor
                    strongSelf.bottomStripeNode.backgroundColor = item.theme.list.itemBlocksSeparatorColor

                    if strongSelf.backgroundNode.supernode == nil {
                        strongSelf.insertSubnode(strongSelf.backgroundNode, at: 0)
                    }
                    if strongSelf.topStripeNode.supernode == nil {
                        strongSelf.insertSubnode(strongSelf.topStripeNode, at: 1)
                    }
                    if strongSelf.bottomStripeNode.supernode == nil {
                        strongSelf.insertSubnode(strongSelf.bottomStripeNode, at: 2)
                    }
                    if strongSelf.maskNode.supernode == nil {
                        strongSelf.insertSubnode(strongSelf.maskNode, at: 3)
                    }

                    let hasCorners = itemListHasRoundedBlockLayout(params)
                    var hasTopCorners = false
                    var hasBottomCorners = false
                    switch neighbors.top {
                    case .sameSection(false):
                        strongSelf.topStripeNode.isHidden = true
                    default:
                        hasTopCorners = true
                        strongSelf.topStripeNode.isHidden = hasCorners
                    }
                    let bottomStripeInset: CGFloat
                    let bottomStripeOffset: CGFloat
                    switch neighbors.bottom {
                    case .sameSection(false):
                        bottomStripeInset = params.leftInset + 16.0
                        bottomStripeOffset = -separatorHeight
                        strongSelf.bottomStripeNode.isHidden = false
                    default:
                        bottomStripeInset = 0.0
                        bottomStripeOffset = 0.0
                        hasBottomCorners = true
                        strongSelf.bottomStripeNode.isHidden = hasCorners
                    }

                    strongSelf.maskNode.image = hasCorners ? PresentationResourcesItemList.cornersImage(item.theme, top: hasTopCorners, bottom: hasBottomCorners, glass: true) : nil

                    strongSelf.backgroundNode.frame = CGRect(origin: CGPoint(x: 0.0, y: -min(insets.top, separatorHeight)), size: CGSize(width: params.width, height: contentSize.height + min(insets.top, separatorHeight) + min(insets.bottom, separatorHeight)))
                    strongSelf.maskNode.frame = strongSelf.backgroundNode.frame.inset(by: UIEdgeInsets(top: 0.0, left: params.leftInset, bottom: 0.0, right: params.rightInset))
                    strongSelf.topStripeNode.frame = CGRect(origin: CGPoint(x: 0.0, y: -min(insets.top, separatorHeight)), size: CGSize(width: layoutSize.width, height: separatorHeight))
                    strongSelf.bottomStripeNode.frame = CGRect(origin: CGPoint(x: bottomStripeInset, y: contentSize.height + bottomStripeOffset), size: CGSize(width: layoutSize.width - bottomStripeInset - params.rightInset - separatorRightInset, height: separatorHeight))

                    strongSelf.titleNode.attributedText = NSAttributedString(string: item.title, font: Font.regular(17.0), textColor: item.theme.list.itemPrimaryTextColor)
                    strongSelf.valueNode.attributedText = NSAttributedString(string: item.valueText, font: Font.regular(17.0), textColor: item.theme.list.itemSecondaryTextColor)

                    let sideInset: CGFloat = 18.0
                    let valueSize = strongSelf.valueNode.updateLayout(CGSize(width: 120.0, height: 40.0))
                    let titleSize = strongSelf.titleNode.updateLayout(CGSize(width: params.width - params.leftInset - params.rightInset - sideInset * 2.0 - valueSize.width - 8.0, height: 40.0))

                    strongSelf.titleNode.frame = CGRect(origin: CGPoint(x: params.leftInset + sideInset, y: 14.0 + verticalInset), size: titleSize)
                    strongSelf.valueNode.frame = CGRect(origin: CGPoint(x: params.width - params.rightInset - sideInset - valueSize.width, y: 14.0 + verticalInset), size: valueSize)

                    let sliderSize = strongSelf.slider.update(
                        transition: .immediate,
                        component: AnyComponent(
                            SliderComponent(
                                content: .continuous(.init(
                                    value: item.fraction,
                                    minValue: nil,
                                    valueUpdated: { [weak strongSelf] value in
                                        strongSelf?.item?.updated(value)
                                    }
                                )),
                                useNative: true,
                                trackBackgroundColor: item.theme.list.itemSwitchColors.frameColor,
                                trackForegroundColor: item.theme.list.itemAccentColor
                            )
                        ),
                        environment: {},
                        containerSize: CGSize(width: params.width - params.leftInset - params.rightInset - 15.0 * 2.0, height: 44.0)
                    )
                    if let sliderView = strongSelf.slider.view {
                        if sliderView.superview == nil {
                            strongSelf.view.addSubview(sliderView)
                        }
                        sliderView.frame = CGRect(origin: CGPoint(x: floorToScreenPixels((params.width - sliderSize.width) / 2.0), y: 36.0 + verticalInset), size: sliderSize)
                    }
                }
            })
        }
    }

    override func animateInsertion(_ currentTimestamp: Double, duration: Double, options: ListViewItemAnimationOptions) {
        self.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.4)
    }

    override func animateRemoved(_ currentTimestamp: Double, duration: Double) {
        self.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.15, removeOnCompletion: false)
    }
}
