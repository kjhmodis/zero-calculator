
import UIKit

class EquationViewLayout : UICollectionViewLayout
{
    //MARK: - Instance
    
    var layoutAttributes            = [UICollectionViewLayoutAttributes]()
    let cellPadding     : CGFloat   = 4
    var originX         : CGFloat   = 0
    var originY         : CGFloat   = 0
    var contentWidth    : CGFloat   = 0
    var contentHeight   : CGFloat   = 0
    
    override init()
    {
        super.init()
    }
    
    required init?(coder aDecoder : NSCoder)
    {
        super.init(coder : aDecoder)
    }
    
    
    //MARK: - Override
    
    
    override func prepare()
    {
        super.prepare()
        
        //reset cache
        self.layoutAttributes.removeAll()
        
        //prepare layout
        let refHeight       = cellHeight
        self.originX        = 0
        self.originY        = 0
        self.contentWidth   = 0
        self.contentHeight  = refHeight
        
        //set contentSize
        self.collectionView!.contentSize = CGSize(width : self.contentWidth, height : self.contentHeight)
        
        //enable scroll
        self.collectionView?.isScrollEnabled = true
        
        if layoutAttributes.isEmpty
        {
            let numberOfItems = self.collectionView?.numberOfItems(inSection : 0)
            
            for item in 0 ..< numberOfItems!
            {
                //indexPath
                let indexPath   = IndexPath(item : item, section : 0)
                let _indexPath  = (self.collectionView as! CollectionView).indexPath
                
                //model
                let tag         = self.collectionView!.tag
                let equation    = tag == 10 ? calculator.currentEquations[_indexPath.item] :
                                              calculator.equationSections[_indexPath.section][_indexPath.item]
                
                //itemSize
                let itemSize    = SM.itemSize(forEquation : equation, indexPath : indexPath,
                                              collectionView : self.collectionView!)
                
                //fetch attributes
                let attributes = UICollectionViewLayoutAttributes(forCellWith : indexPath)
                
                //set frame
                attributes.frame = CGRect(x : self.originX, y : self.originY, width : itemSize.width, height : refHeight)
                
                //add to cache
                self.layoutAttributes.append(attributes)
                
                //update origin
                self.originX += itemSize.width + (self.cellPadding * 2)
                
                //enlarge contentWidth
                self.contentWidth += attributes.frame.width + (self.cellPadding * 2)
                
                //adjust contentSize
                self.collectionView!.contentSize = CGSize(width : self.contentWidth, height : self.contentHeight)
            }
        }
    }
    
    override var collectionViewContentSize : CGSize
    {
        return CGSize(width : self.contentWidth, height : self.contentHeight)
    }
    
    override func layoutAttributesForElements(in rect : CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        var attributes = [UICollectionViewLayoutAttributes]()
        for attribute in self.layoutAttributes
        {
            if attribute.frame.intersects(rect)
            {
                attributes.append(attribute)
            }
        }
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath : IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return self.layoutAttributes[indexPath.item]
    }
    
    override func prepare(forCollectionViewUpdates updateItems : [UICollectionViewUpdateItem])
    {
        super.prepare(forCollectionViewUpdates: updateItems)
    }
    
    override func finalizeCollectionViewUpdates()
    {
        super.finalizeCollectionViewUpdates()
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath : IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return super.initialLayoutAttributesForAppearingItem(at : itemIndexPath)
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath : IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return super.finalLayoutAttributesForDisappearingItem(at : itemIndexPath)
    }
    
}
