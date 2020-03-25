
import UIKit
import MessageUI

class Collection : NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate
{
    //MARK: - Instance
    
    //singleton
    static let sharedInstance       = Collection()
    
    //model
    
    /* settingsList */
    lazy var settingTitles          = [["#setting".local],
                                       ["S1.suggest".local, "S1.review".local],
                                       ["S1.support".local],
                                       ["S1.version".local, "S1.legal".local],
                                       ["S1.reset".local]]
    
    var settingIcons : [[Icon]]     = [[.Settings],
                                       [.Recommend, .Review],
                                       [.Support],
                                       [.Version, .Legal]]
    
    //detailedItems
    let detailedSettings            = [IndexPath(row : 0, section : 0), IndexPath(row : 0, section : 2),
                                       IndexPath(row : 0, section : 3), IndexPath(row : 1, section : 3)]
    
    /* settingsList */
    lazy var settingDepthItems      = [["S2-1-1.english".local, "S2-1-1.sound".local,
                                        "S2-1-1.autoSave".local, "S2-1-1.decimal".local],
                                       ["S2-1-2.theme".local, "S2-1-2.font".local]]
    lazy var supportDepthItems      = [["S2-2.inquire".local], ["S2-2.suggest".local],
                                       ["S2-2.trouble".local], ["S2-2.translate".local]]
    lazy var legalDepthItems        = ["S2-3.attributions".local, "S2-3.privacy".local, "S2-3.disclaimer".local]
    
    var operationOffset             = CGPoint.zero
    var searchOffset                = CGPoint(x : -(refWidth * 0.035), y : 0)
    
    var operationSelected           = false
    var searchSelected              = false
    
    override init()
    {
        //init super
        super.init()
    }
    
    
    //MARK: - Configure
    
    
    func configureRecentSections()
    {
        //prepare
        let sectionTitles = ["T", "Y", "1W", "2W", "1M", "3M", "6M", "1Y", "~", "F"]
        calculator.entityIndexTitles = sectionTitles
        
        let sectionCount = sectionTitles.count
        var sectionTitlesToRemove = [String]()
        let dateSortDescriptor = NSSortDescriptor(key : "createdDate", ascending : false)
        let sortDescriptors = [dateSortDescriptor]
        
        switch calculator.recentState
        {
        case .RecentEquation :
            var unsortedSections    = [[Equation]]()
            var sortedSections      = [[Equation]]()
            
            //init fresh section array
            for _ in 0..<sectionCount
            {
                unsortedSections.append([Equation]())
            }
            
            //sort model
            for equation in calculator.recentEquations
            {
                let index = calculator.sectionIndex(forDate : equation.recentDate)
                unsortedSections[index].append(equation)
            }
            
            //prepare empty section remove
            for (index, unsortedSection) in unsortedSections.enumerated()
            {
                //section empty
                if unsortedSection.count == 0
                {
                    sectionTitlesToRemove.append(calculator.entityIndexTitles[index])
                }
                //section not empty
                else
                {
                    let sortedSection = (unsortedSection as NSArray).sortedArray(using : sortDescriptors) as! [Equation]
                    sortedSections.append(sortedSection)
                }
            }
            
            //update
            calculator.equationSections = sortedSections
            
        case .RecentValue :
            var unsortedSections    = [[Value]]()
            var sortedSections      = [[Value]]()
            
            //init fresh section array
            for _ in 0..<sectionCount
            {
                unsortedSections.append([Value]())
            }
            
            //sort model
            for value in calculator.recentValues
            {
                let index = calculator.sectionIndex(forDate : value.recentDate)
                unsortedSections[index].append(value)
            }
            
            //prepare empty section remove
            for (index, unsortedSection) in unsortedSections.enumerated()
            {
                //section empty
                if unsortedSection.count == 0
                {
                    sectionTitlesToRemove.append(calculator.entityIndexTitles[index])
                }
                //section not empty
                else
                {
                    let sortedSection = (unsortedSection as NSArray).sortedArray(using : sortDescriptors) as! [Value]
                    sortedSections.append(sortedSection)
                }
            }
            
            //update
            calculator.valueSections = sortedSections
            
        default : break
        }
        
        //filter index titles
        let refinedSectionIndexTitles = calculator.entityIndexTitles.filter({
            !sectionTitlesToRemove.contains($0)
        })
        calculator.entityIndexTitles = refinedSectionIndexTitles
        
        //customize index titles
        calculator.recentList.sectionIndexColor                     = SM.highlightedColor()
        calculator.recentList.sectionIndexBackgroundColor           = .clear
        calculator.recentList.sectionIndexTrackingBackgroundColor   = .clear
        
        //reload
        calculator.recentList.reloadData()
    }
    
    func configureGroupSections()
    {
        //set index titles
        let collation = UILocalizedIndexedCollation.current()
        
        if calculator.manageDisplayed
        {
            calculator.entityIndexTitles = collation.sectionIndexTitles
        }
        else
        {
            calculator.sectionIndexTitles = collation.sectionIndexTitles
        }
        
        let sectionCount = calculator.manageDisplayed ? calculator.entityIndexTitles.count :
                                                        calculator.sectionIndexTitles.count
        
        var unsortedSections = [[Group]]()
        
        //init fresh unit array for each section
        for _ in 0..<sectionCount
        {
            unsortedSections.append([Group]())
        }
        
        //fetch reference model
        for group in calculator.groups
        {
            let index = collation.section(for : group, collationStringSelector : #selector(getter : Group.name))
            
            //validate
            if unsortedSections.indices.contains(index)
            {
                unsortedSections[index].append(group)
            }
            else
            {
                if unsortedSections.indices.contains(index - 1)
                {
                    unsortedSections[index - 1].append(group)
                }
                else
                {
                    continue
                }
            }
            
        }
        
        //sort
        var sortedSections = [[Group]]()
        var sectionTitlesToRemove = [String]()
        
        let nameSortDescriptor = NSSortDescriptor(key : "name", ascending : true, selector : #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        let sortDescriptors = [nameSortDescriptor]
        
        for (index, unsortedSection) in unsortedSections.enumerated()
        {
            //section is empty
            if unsortedSection.count == 0
            {
                sectionTitlesToRemove.append(calculator.manageDisplayed ?
                calculator.entityIndexTitles[index] : calculator.sectionIndexTitles[index])
            }
            //section is not empty
            else
            {
                let sortedSection = (unsortedSection as NSArray).sortedArray(using : sortDescriptors) as! [Group]
                sortedSections.append(sortedSection)
            }
        }
        
        let refinedSectionIndexTitles = calculator.manageDisplayed ?
                                        calculator.entityIndexTitles.filter ({ !sectionTitlesToRemove.contains($0) }) :
                                        calculator.sectionIndexTitles.filter({ !sectionTitlesToRemove.contains($0) })
        
        if calculator.manageDisplayed
        {
            calculator.entityIndexTitles = refinedSectionIndexTitles
        }
        else
        {
            calculator.sectionIndexTitles = refinedSectionIndexTitles
        }
        calculator.groupSections = sortedSections
        
        //customize index titles
        calculator.groupList.sectionIndexColor                          = SM.highlightedColor()
        calculator.groupList.sectionIndexBackgroundColor                = .clear
        calculator.groupList.sectionIndexTrackingBackgroundColor        = .clear
        
        calculator.groupList.reloadData()
    }
    
    func configureGroupEntitySections()
    {
        //prepare
        let collation = UILocalizedIndexedCollation.current()
        calculator.entityIndexTitles = collation.sectionIndexTitles
    
        let sectionCount = calculator.entityIndexTitles.count
        var sectionTitlesToRemove = [String]()
        
        let nameSortDescriptor = NSSortDescriptor(key : "name", ascending : true, selector : #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        let sortDescriptors = [nameSortDescriptor]
        
        switch calculator.groupState
        {
        case .GroupEquation :
            var unsortedSections    = [[Equation]]()
            var sortedSections      = [[Equation]]()
            var equations           = [Equation]()
            
            //init fresh section array
            for _ in 0..<sectionCount
            {
                unsortedSections.append([Equation]())
            }
            
            //fetch model
            if let selectedGroup = calculator.selectedGroup
            {
                equations = selectedGroup.fetchEquations()
            }
            
            //sort model
            for equation in equations
            {
                let index = collation.section(for : equation, collationStringSelector : #selector(getter : Equation.name))
                
                //validate
                if unsortedSections.indices.contains(index)
                {
                    unsortedSections[index].append(equation)
                }
                else
                {
                    if unsortedSections.indices.contains(index - 1)
                    {
                        unsortedSections[index - 1].append(equation)
                    }
                    else
                    {
                        continue
                    }
                }
                
            }
            
            //prepare empty section remove
            for (index, unsortedSection) in unsortedSections.enumerated()
            {
                //section empty
                if unsortedSection.count == 0
                {
                    sectionTitlesToRemove.append(calculator.entityIndexTitles[index])
                }
                //section not empty
                else
                {
                    let sortedSection = (unsortedSection as NSArray).sortedArray(using : sortDescriptors) as! [Equation]
                    sortedSections.append(sortedSection)
                }
            }
            
            //update
            calculator.equationSections = sortedSections
            
        case .GroupValue :
            var unsortedSections    = [[Value]]()
            var sortedSections      = [[Value]]()
            var values              = [Value]()
            
            //init fresh section array
            for _ in 0..<sectionCount
            {
                unsortedSections.append([Value]())
            }
            
            //fetch model
            if let selectedGroup = calculator.selectedGroup
            {
                values = selectedGroup.fetchValues()
            }
            
            //sort model
            for value in values
            {
                let index = collation.section(for : value, collationStringSelector : #selector(getter : Value.name))
                
                //validate
                if unsortedSections.indices.contains(index)
                {
                    unsortedSections[index].append(value)
                }
                else
                {
                    if unsortedSections.indices.contains(index - 1)
                    {
                        unsortedSections[index - 1].append(value)
                    }
                    else
                    {
                        continue
                    }
                }

            }
            
            //prepare empty section remove
            for (index, unsortedSection) in unsortedSections.enumerated()
            {
                //section empty
                if unsortedSection.count == 0
                {
                    sectionTitlesToRemove.append(calculator.entityIndexTitles[index])
                }
                //section not empty
                else
                {
                    let sortedSection = (unsortedSection as NSArray).sortedArray(using : sortDescriptors) as! [Value]
                    sortedSections.append(sortedSection)
                }
            }
            
            //update
            calculator.valueSections = sortedSections
            
        case .GroupTag :
            var unsortedSections    = [[Tag]]()
            var sortedSections      = [[Tag]]()
            var tags                = [Tag]()
            
            //init fresh section array
            for _ in 0..<sectionCount
            {
                unsortedSections.append([Tag]())
            }
            
            //fetch model
            if let selectedGroup = calculator.selectedGroup
            {
                tags = selectedGroup.fetchTags()
            }
            
            //fetch model
            for tag in tags
            {
                let index = collation.section(for : tag, collationStringSelector : #selector(getter : Tag.name))
                
                //validate
                if unsortedSections.indices.contains(index)
                {
                    unsortedSections[index].append(tag)
                }
                else
                {
                    if unsortedSections.indices.contains(index - 1)
                    {
                        unsortedSections[index - 1].append(tag)
                    }
                    else
                    {
                        continue
                    }
                }
                
            }
            
            //prepare empty section remove
            for (index, unsortedSection) in unsortedSections.enumerated()
            {
                //section empty
                if unsortedSection.count == 0
                {
                    sectionTitlesToRemove.append(calculator.entityIndexTitles[index])
                }
                //section not empty
                else
                {
                    let sortedSection = (unsortedSection as NSArray).sortedArray(using : sortDescriptors) as! [Tag]
                    sortedSections.append(sortedSection)
                }
            }
            
            //update
            calculator.tagSections = sortedSections
            
        default : break
        }
        
        //filter index titles
        let refinedSectionIndexTitles = calculator.entityIndexTitles.filter({
            !sectionTitlesToRemove.contains($0)
        })
        calculator.entityIndexTitles = refinedSectionIndexTitles
        
        //customize index titles
        calculator.groupEntityList.sectionIndexColor                     = SM.highlightedColor()
        calculator.groupEntityList.sectionIndexBackgroundColor           = .clear
        calculator.groupEntityList.sectionIndexTrackingBackgroundColor   = .clear
        
        //reload
        calculator.groupEntityList.reloadData()
    }
    
    func configureTagSections()
    {
        //set index titles
        let collation = UILocalizedIndexedCollation.current()
        calculator.entityIndexTitles = collation.sectionIndexTitles

        let sectionCount = calculator.entityIndexTitles.count
        
        var unsortedSections = [[Tag]]()
        
        //init fresh tag array for each section
        for _ in 0..<sectionCount
        {
            unsortedSections.append([Tag]())
        }
        
        //fetch reference model
        for tag in calculator.tags
        {
            let index = collation.section(for : tag, collationStringSelector : #selector(getter : Tag.name))
            
            //validate
            if unsortedSections.indices.contains(index)
            {
                unsortedSections[index].append(tag)
            }
            else
            {
                if unsortedSections.indices.contains(index - 1)
                {
                    unsortedSections[index - 1].append(tag)
                }
                else
                {
                    continue
                }
            }
        }
        
        //sort
        var sortedSections = [[Tag]]()
        var sectionTitlesToRemove = [String]()
        
        let nameSortDescriptor = NSSortDescriptor(key : "name", ascending : true, selector : #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        let sortDescriptors = [nameSortDescriptor]
        
        for (index, unsortedSection) in unsortedSections.enumerated()
        {
            //section is empty
            if unsortedSection.count == 0
            {
                sectionTitlesToRemove.append(calculator.entityIndexTitles[index])
            }
            //section is not empty
            else
            {
                let sortedSection = (unsortedSection as NSArray).sortedArray(using : sortDescriptors) as! [Tag]
                sortedSections.append(sortedSection)
            }
        }
        
        let refinedSectionIndexTitles   = calculator.entityIndexTitles.filter({ !sectionTitlesToRemove.contains($0) })
        
        calculator.entityIndexTitles    = refinedSectionIndexTitles
        calculator.tagSections          = sortedSections
        
        //customize index titles
        calculator.tagList.sectionIndexColor                          = SM.highlightedColor()
        calculator.tagList.sectionIndexBackgroundColor                = .clear
        calculator.tagList.sectionIndexTrackingBackgroundColor        = .clear
        
        calculator.tagList.reloadData()
    }
    
    func configureUnitSections()
    {
        let collation = UILocalizedIndexedCollation.current()
        calculator.sectionIndexTitles = collation.sectionIndexTitles
        
        let sectionCount = calculator.sectionIndexTitles.count
        
        var unsortedSections = [[Unit]]()
        
        //init fresh unit array for each section
        for _ in 0..<sectionCount
        {
            unsortedSections.append([Unit]())
        }
        
        //fetch reference model
        let units = calculator.selectedUnitGroup!.fetchUnits()
        for unit in units
        {
            let index = collation.section(for : unit, collationStringSelector : #selector(getter : Unit.name))
            
            //validate
            if unsortedSections.indices.contains(index)
            {
                unsortedSections[index].append(unit)
            }
            else
            {
                if unsortedSections.indices.contains(index - 1)
                {
                    unsortedSections[index - 1].append(unit)
                }
                else
                {
                    continue
                }
            }
        }
        
        //sort
        var sortedSections = [[Unit]]()
        var sectionTitlesToRemove = [String]()
        
        let nameSortDescriptor = NSSortDescriptor(key : "name", ascending : true, selector : #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        let sortDescriptors = [nameSortDescriptor]
        
        for (index, unsortedSection) in unsortedSections.enumerated()
        {
            //section is empty
            if unsortedSection.count == 0
            {
                sectionTitlesToRemove.append(calculator.sectionIndexTitles[index])
            }
            //section is not empty
            else
            {
                let sortedSection = (unsortedSection as NSArray).sortedArray(using : sortDescriptors) as! [Unit]
                sortedSections.append(sortedSection)
            }
        }
        
        let refinedSectionIndexTitles = calculator.sectionIndexTitles.filter({
            !sectionTitlesToRemove.contains($0)
        })
        calculator.sectionIndexTitles = refinedSectionIndexTitles
        calculator.currencySections = sortedSections
        
        //customize index titles
        calculator.unitPickerList.sectionIndexColor                      = SM.highlightedColor()
        calculator.unitPickerList.sectionIndexBackgroundColor            = .clear
        calculator.unitPickerList.sectionIndexTrackingBackgroundColor    = .clear
        
        calculator.unitPickerList.reloadData()
    }
    
    func configureManageSections()
    {
        //prepare
        let collation = UILocalizedIndexedCollation.current()
        calculator.sectionIndexTitles = collation.sectionIndexTitles
        
        let sectionCount = calculator.sectionIndexTitles.count
        
        var sectionTitlesToRemove = [String]()
        
        let nameSortDescriptor = NSSortDescriptor(key : "name", ascending : true, selector : #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        let sortDescriptors = [nameSortDescriptor]
        
        switch calculator.entityState
        {
        case .EntityGroup :
            var unsortedSections    = [[Group]]()
            var sortedSections      = [[Group]]()
            
            //init fresh section array
            for _ in 0..<sectionCount
            {
                unsortedSections.append([Group]())
            }
            
            //place model
            for group in calculator.groups
            {
                let index = collation.section(for : group, collationStringSelector : #selector(getter : Group.name))
                
                //validate
                if unsortedSections.indices.contains(index)
                {
                    unsortedSections[index].append(group)
                }
                else
                {
                    if unsortedSections.indices.contains(index - 1)
                    {
                        unsortedSections[index - 1].append(group)
                    }
                    else
                    {
                        continue
                    }
                }
            }
            
            //sort
            for (index, unsortedSection) in unsortedSections.enumerated()
            {
                //section empty
                if unsortedSection.count == 0
                {
                    sectionTitlesToRemove.append(calculator.sectionIndexTitles[index])
                }
                //section not empty
                else
                {
                    let sortedSection = (unsortedSection as NSArray).sortedArray(using : sortDescriptors) as! [Group]
                    sortedSections.append(sortedSection)
                }
            }
            
            //update
            calculator.groupSections = sortedSections
            
        case .EntityEquation :
            var unsortedSections    = [[Equation]]()
            var sortedSections      = [[Equation]]()
            var equations           = [Equation]()
            
            //init fresh section array
            for _ in 0..<sectionCount
            {
                unsortedSections.append([Equation]())
            }
            
            //fetch model
            equations = calculator.viewState == .ManageSearch && !calculator.manageEditing || !calculator.manageDisplayed &&
                        !calculator.manageEditing ? calculator.searchedEquations : calculator.manageSelectedGroup != nil ?
                        calculator.manageSelectedGroup!.fetchEquations() : calculator.equations
            
            //place model
            for equation in equations
            {
                let index = collation.section(for : equation, collationStringSelector : #selector(getter : Equation.name))
                
                //validate
                if unsortedSections.indices.contains(index)
                {
                    unsortedSections[index].append(equation)
                }
                else
                {
                    if unsortedSections.indices.contains(index - 1)
                    {
                        unsortedSections[index - 1].append(equation)
                    }
                    else
                    {
                        continue
                    }
                }
            }
            
            //sort
            for (index, unsortedSection) in unsortedSections.enumerated()
            {
                //section empty
                if unsortedSection.count == 0
                {
                    sectionTitlesToRemove.append(calculator.sectionIndexTitles[index])
                }
                //section not empty
                else
                {
                    let sortedSection = (unsortedSection as NSArray).sortedArray(using : sortDescriptors) as! [Equation]
                    sortedSections.append(sortedSection)
                }
            }
            
            //update
            calculator.equationSections = sortedSections
            
        case .EntityValue :
            var unsortedSections    = [[Value]]()
            var sortedSections      = [[Value]]()
            var values              = [Value]()
            
            //init fresh section array
            for _ in 0..<sectionCount
            {
                unsortedSections.append([Value]())
            }
            
            //fetch model
            values = calculator.viewState == .ManageSearch && !calculator.manageEditing || !calculator.manageDisplayed &&
                     !calculator.manageEditing ? calculator.searchedValues : calculator.manageSelectedGroup != nil ?
                     calculator.manageSelectedGroup!.fetchValues() : calculator.values
            
            //place model
            for value in values
            {
                let index = collation.section(for : value, collationStringSelector : #selector(getter : Value.name))
                
                //validate
                if unsortedSections.indices.contains(index)
                {
                    unsortedSections[index].append(value)
                }
                else
                {
                    if unsortedSections.indices.contains(index - 1)
                    {
                        unsortedSections[index - 1].append(value)
                    }
                    else
                    {
                        continue
                    }
                }
                
            }
            
            //sort
            for (index, unsortedSection) in unsortedSections.enumerated()
            {
                //section empty
                if unsortedSection.count == 0
                {
                    sectionTitlesToRemove.append(calculator.sectionIndexTitles[index])
                }
                //section not empty
                else
                {
                    let sortedSection = (unsortedSection as NSArray).sortedArray(using : sortDescriptors) as! [Value]
                    sortedSections.append(sortedSection)
                }
            }
            
            //update
            calculator.valueSections = sortedSections
            
        case .EntityTag :
            var unsortedSections    = [[Tag]]()
            var sortedSections      = [[Tag]]()
            var tags                = [Tag]()
            
            //init fresh section array
            for _ in 0..<sectionCount
            {
                unsortedSections.append([Tag]())
            }
            
            //fetch model
            tags = calculator.viewState == .ManageSearch || !calculator.manageDisplayed ? calculator.searchedTags :
                   calculator.manageSelectedGroup != nil ? calculator.manageSelectedGroup!.fetchTags() : calculator.tags
            
            //place model
            for tag in tags
            {
                let index = collation.section(for : tag, collationStringSelector : #selector(getter : Tag.name))
                
                //validate
                if unsortedSections.indices.contains(index)
                {
                    unsortedSections[index].append(tag)
                }
                else
                {
                    if unsortedSections.indices.contains(index - 1)
                    {
                        unsortedSections[index - 1].append(tag)
                    }
                    else
                    {
                        continue
                    }
                }
            }
            
            //sort
            for (index, unsortedSection) in unsortedSections.enumerated()
            {
                //section empty
                if unsortedSection.count == 0
                {
                    sectionTitlesToRemove.append(calculator.sectionIndexTitles[index])
                }
                //section not empty
                else
                {
                    let sortedSection = (unsortedSection as NSArray).sortedArray(using : sortDescriptors) as! [Tag]
                    sortedSections.append(sortedSection)
                }
            }
            
            //update
            calculator.tagSections = sortedSections
            
        default : break
        }
        
        //filter index titles
        let refinedSectionIndexTitles = calculator.sectionIndexTitles.filter({
            !sectionTitlesToRemove.contains($0)
        })
        calculator.sectionIndexTitles = refinedSectionIndexTitles
        
        //customize index titles
        calculator.manageList.sectionIndexColor                     = SM.highlightedColor()
        calculator.manageList.sectionIndexBackgroundColor           = .clear
        calculator.manageList.sectionIndexTrackingBackgroundColor   = .clear
        
        //reload
        calculator.manageList.reloadData()
        
        //scroll to target
        var targetPath : IndexPath
        switch calculator.fieldState
        {
        case .CreateGroup :
            for (sectionIndex, section) in calculator.groupSections.enumerated()
            {
                for (rowIndex, _group) in section.enumerated()
                {
                    if _group == calculator.groups.last!
                    {
                        targetPath = IndexPath(row : rowIndex, section : sectionIndex)
                        calculator.manageList.scrollToRow(at : targetPath, at : .middle, animated : false)
                        break
                    }
                }
            }
            
        case .CreateEquation :
            for (sectionIndex, section) in calculator.equationSections.enumerated()
            {
                for (rowIndex, _equation) in section.enumerated()
                {
                    if _equation == calculator.equations.last!
                    {
                        targetPath = IndexPath(row : rowIndex, section : sectionIndex)
                        calculator.manageList.scrollToRow(at : targetPath, at : .middle, animated : false)
                        break
                    }
                }
            }
            
        case .CreateValue :
            for (sectionIndex, section) in calculator.valueSections.enumerated()
            {
                for (rowIndex, _value) in section.enumerated()
                {
                    if _value == calculator.values.last!
                    {
                        targetPath = IndexPath(row : rowIndex, section : sectionIndex)
                        calculator.manageList.scrollToRow(at : targetPath, at : .middle, animated : false)
                        break
                    }
                }
            }

        case .CreateTag :
            for (sectionIndex, section) in calculator.tagSections.enumerated()
            {
                for (rowIndex, _tag) in section.enumerated()
                {
                    if _tag == calculator.tags.last!
                    {
                        targetPath = IndexPath(row : rowIndex, section : sectionIndex)
                        calculator.manageList.scrollToRow(at : targetPath, at : .middle, animated : false)
                        break
                    }
                }
            }
            
        default : break
        }
        
    }
    
    func configureTagEntitySections()
    {
        //prepare
        let collation = UILocalizedIndexedCollation.current()
        calculator.sectionIndexTitles = collation.sectionIndexTitles

        let sectionCount = calculator.sectionIndexTitles.count
        
        var sectionTitlesToRemove = [String]()
        
        let nameSortDescriptor = NSSortDescriptor(key : "name", ascending : true, selector :
                                 #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        let sortDescriptors = [nameSortDescriptor]
        
        switch calculator.entityState
        {
        case .EntityEquation :
            var unsortedSections    = [[Equation]]()
            var sortedSections      = [[Equation]]()
            
            //init fresh section array
            for _ in 0..<sectionCount
            {
                unsortedSections.append([Equation]())
            }
            
            //fetch & dispense model
            for equation in calculator.selectedTag!.fetchEquations()
            {
                let index = collation.section(for : equation, collationStringSelector : #selector(getter : Equation.name))
                
                //validate
                if unsortedSections.indices.contains(index)
                {
                    unsortedSections[index].append(equation)
                }
                else
                {
                    if unsortedSections.indices.contains(index - 1)
                    {
                        unsortedSections[index - 1].append(equation)
                    }
                    else
                    {
                        continue
                    }
                }
            }
            
            //sort
            for (index, unsortedSection) in unsortedSections.enumerated()
            {
                //section empty
                if unsortedSection.count == 0
                {
                    sectionTitlesToRemove.append(calculator.sectionIndexTitles[index])
                }
                //section not empty
                else
                {
                    let sortedSection = (unsortedSection as NSArray).sortedArray(using : sortDescriptors) as! [Equation]
                    sortedSections.append(sortedSection)
                }
            }
            
            //update
            calculator.equationSections = sortedSections
            
        case .EntityValue :
            var unsortedSections    = [[Value]]()
            var sortedSections      = [[Value]]()
            
            //init fresh section array
            for _ in 0..<sectionCount
            {
                unsortedSections.append([Value]())
            }
            
            //fetch & dispense model
            for value in calculator.selectedTag!.fetchValues()
            {
                let index = collation.section(for : value, collationStringSelector : #selector(getter : Value.name))
                
                //validate
                if unsortedSections.indices.contains(index)
                {
                    unsortedSections[index].append(value)
                }
                else
                {
                    if unsortedSections.indices.contains(index - 1)
                    {
                        unsortedSections[index - 1].append(value)
                    }
                    else
                    {
                        continue
                    }
                }
            }
            
            //sort
            for (index, unsortedSection) in unsortedSections.enumerated()
            {
                //section empty
                if unsortedSection.count == 0
                {
                    sectionTitlesToRemove.append(calculator.sectionIndexTitles[index])
                }
                //section not empty
                else
                {
                    let sortedSection = (unsortedSection as NSArray).sortedArray(using : sortDescriptors) as! [Value]
                    sortedSections.append(sortedSection)
                }
            }
            
            //update
            calculator.valueSections = sortedSections
            
        default : break
        }
        
        //filter index titles
        let refinedSectionIndexTitles = calculator.sectionIndexTitles.filter({
            !sectionTitlesToRemove.contains($0)
        })
        calculator.sectionIndexTitles = refinedSectionIndexTitles
        
        //customize index titles
        calculator.modelList.sectionIndexColor                     = SM.highlightedColor()
        calculator.modelList.sectionIndexBackgroundColor           = .clear
        calculator.modelList.sectionIndexTrackingBackgroundColor   = .clear
        
        //reload
        calculator.modelList.reloadData()
    }
    
    
    //MARK: - Custom
    
    
    func itemCell(forEquation equation : Equation, indexPath : IndexPath, identifier : String,
                  collectionView : UICollectionView) -> ItemCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier : identifier, for : indexPath) as! ItemCell
        
        //equation
        if indexPath.item == 0
        {
            //activate
            cell.activate(equation : equation)
        }
        //equal
        else if indexPath.item == 1
        {
            cell.activateEqual()
        }
        //value
        else if (indexPath.item - 2) % 2 == 0
        {
            //fetch value
            let index = (indexPath.item - 2) / 2
            let value = equation.values![index] as! Value
            
            //activate
            cell.activate(value : value, collectionView : collectionView as! CollectionView)
        }
        //operation
        else
        {
            //fetch operation
            let index       = (indexPath.item - 2 - 1) / 2
            let operation   = equation.operations![index] as! Operation
            
            //activate
            cell.activate(operation : operation, collectionView : collectionView as! CollectionView)
        }
        
        return cell
    }
    
    func itemSelected(forEquation equation : Equation, indexPath : IndexPath, collectionView : UICollectionView)
    {
        //equation
        if indexPath.item == 0
        {
            SM.adjustSelection(withState : .Equation)
            
            equation.select()
            equation.hit()
            
            calculator.control.layout(cancel : .Equation)
            
            calculator.selectFrom = .List
            calculator.selectionView.equation(selectFrom : calculator.selectFrom)
        }
        //equal
        else if indexPath.item == 1
        {
            return
        }
        //value
        else if (indexPath.item - 2) % 2 == 0
        {
            //fetch value
            let index = (indexPath.item - 2) / 2
            let value = equation.values![index] as! Value
            
            //validate
            if calculator.currentEquation!.fetchValues().contains(value) && calculator.operationState == .WillSwitch
            {
                let mutableOrderedSet = NSMutableOrderedSet(orderedSet : calculator.currentEquation!.values!)
                let fromIndex = mutableOrderedSet.index(of : calculator.selectedValue!)
                
                //exchange sourceCell with destinationCell
                mutableOrderedSet.exchangeObject(at : fromIndex, withObjectAt : index)
                
                //save re-ordered values
                calculator.currentEquation!.values = mutableOrderedSet
                
                //update
                calculator.calculate(equation : calculator.currentEquation!)
                calculator.modelList.reloadData()
                
                calculator.cancel(state : .ValueAction)
                
                return
            }
            else
            {
                SM.adjustSelection(withState : .Value)
                
                value.select()
                value.hit()
                
                calculator.control.layout(cancel : .Value)
                
                calculator.selectFrom = .List
                calculator.selectionView.value(selectFrom : calculator.selectFrom)
            }
        }
        //operation
        else
        {
            //display equation instead
            SM.adjustSelection(withState : .Equation)
            
            equation.select()
            
            calculator.control.layout(cancel : .Equation)
            
            calculator.selectFrom = .List
            calculator.selectionView.equation(selectFrom : calculator.selectFrom)
        }
        
        //reload
        calculator.equationField.inputView = calculator.selectionView
        calculator.equationField.reloadInputViews()
        
        //display infoView
        calculator.infoView.show()
    }
    
    func itemSelected(forValue value : Value)
    {
        SM.adjustSelection(withState : .Value)
        
        value.select()
        
        calculator.control.layout(cancel : .Value)
        
        calculator.selectFrom = .List
        calculator.selectionView.value(selectFrom : calculator.selectFrom)
        
        //reload
        calculator.equationField.inputView = calculator.selectionView
        calculator.equationField.reloadInputViews()
        
        //display infoView
        calculator.infoView.show()
    }
    
    
    //MARK: - UICollectionView DataSource
    
    
    func numberOfSections(in collectionView : UICollectionView) -> Int
    {
        return collectionView == calculator.searchView ? 2 : 1
    }
    
    func collectionView(_ collectionView : UICollectionView, numberOfItemsInSection section : Int) -> Int
    {
        switch collectionView
        {
        case calculator.operationView :
            return calculator.currentEquation!.valueCount() + calculator.currentEquation!.operationCount()
        
        case calculator.searchView :
            return section == 0 ? calculator.searchedEquations.count : calculator.searchedValues.count
        
        case calculator.themeView :
            return calculator.themes.count
        
        default :
            //prepare model
            var equation    : Equation
            let indexPath   = (collectionView as! CollectionView).indexPath
            
            switch collectionView.tag
            {
            //equationList, recentList, grounEntityList, manageList, modelList (equationView)
            case 10, 20, 30, 40, 50 :
                equation = collectionView.tag == 10 ? calculator.currentEquations[indexPath.row] :
                                                      calculator.equationSections[indexPath.section][indexPath.row]
                return 2 + equation.valueCount() + equation.operationCount()
            
            //modelList (modelView)
            case 60 :
                switch calculator.selectedState
                {
                case .Equation, .SearchedEquation :
                    let targetEquation = calculator.selectedState == .Equation ?
                        calculator.selectedEquation : calculator.selectedSearchedEquation
                    
                    if indexPath.section == 0
                    {
                        if let holdingValue = DM.fetchValue(withEquationUID : targetEquation!.uid)
                        {
                            if let holdingEquation = DM.fetchEquation(forUID : holdingValue.belongTo)
                            {
                                return 2 + holdingEquation.valueCount() + holdingEquation.operationCount()
                            }
                            return 1
                        }
                    }
                    
                    return 2 + targetEquation!.valueCount() + targetEquation!.operationCount()
                    
                case .Value, .SearchedValue :
                    let targetValue = calculator.selectedState == .Value ?
                                      calculator.selectedValue : calculator.selectedSearchedValue
                    
                    if indexPath.section == 0
                    {
                        if let holdingEquation = DM.fetchEquation(forUID : targetValue!.belongTo)
                        {
                            return 2 + holdingEquation.valueCount() + holdingEquation.operationCount()
                        }
                    }
                    else if let subEquation = DM.fetchEquation(forUID : targetValue!.uid)
                    {
                        return 2 + subEquation.valueCount() + subEquation.operationCount()
                    }
                    
                    return 1
                    
                default :
                    equation = calculator.equationSections[indexPath.section][indexPath.row]
                    return 2 + equation.valueCount() + equation.operationCount()

                }
            
            //metaList (tagView)
            case 70 :
                if calculator.valueField.isFirstResponder
                {
                    switch calculator.fieldState
                    {
                    case .CreateEquation, .CreateValue, .EditEquation, .EditValue :
                        return calculator.entityTags.count
                    
                    default : return 0
                    }
                }
                
                switch calculator.selectedState
                {
                case .Equation          : return calculator.selectedEquation!.tagCount()
                case .SearchedEquation  : return calculator.selectedSearchedEquation!.tagCount()
                case .Value             : return calculator.selectedValue!.tagCount()
                case .SearchedValue     : return calculator.selectedSearchedValue!.tagCount()
                default                 : return 0
                }
                
            //entityView
            case 80 : return 1
            
            default : return 0
            }
        }
    }
    
    func collectionView(_ collectionView : UICollectionView, cellForItemAt indexPath : IndexPath) -> UICollectionViewCell
    {
        switch collectionView
        {
        //operationView
        case calculator.operationView :
            //init cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier : CellID.OperationView.rawValue, for : indexPath)
                       as! ItemCell
            
            /* fetch model (bifurcate) */
            
            //value
            if indexPath.item % 2 == 0
            {
                //model
                let index   = indexPath.item / 2
                let value   = calculator.currentEquation!.values![index] as! Value
                
                //activate
                cell.activate(value : value, collectionView : collectionView as! CollectionView)
            }
            //operation
            else
            {
                //fetch operation
                let index       = (indexPath.item - 1) / 2
                let operation   = calculator.currentEquation!.operations![index] as! Operation
                
                //activate
                cell.activate(operation : operation, collectionView : collectionView as! CollectionView)
            }
        
            return cell
        
        //searchView
        case calculator.searchView :
            var cell : SearchCell
            
            //case
            if indexPath.section == 0
            {
                //model
                let equation = calculator.searchedEquations[indexPath.item]
                
                //init cell
                cell = collectionView.dequeueReusableCell(withReuseIdentifier : CellID.SearchViewE.rawValue,
                                                          for : indexPath) as! SearchCell
                
                //activate
                cell.activate(equation : equation)
            }
            else
            {
                //model
                let value = calculator.searchedValues[indexPath.item]
                
                //init cell
                cell = collectionView.dequeueReusableCell(withReuseIdentifier : CellID.SearchViewV.rawValue,
                                                          for : indexPath) as! SearchCell
                
                //activate
                cell.activate(value : value)
            }
        
            return cell
        
        //themeView
        case calculator.themeView :
            //init cell
            var cell : ThemeCell
            
            //case
            switch indexPath.item
            {
            case 0  : cell = collectionView.dequeueReusableCell(withReuseIdentifier : CellID.ThemeViewWhiteGray.rawValue,
                                                                for : indexPath) as! ThemeCell
                
            case 1  : cell = collectionView.dequeueReusableCell(withReuseIdentifier : CellID.ThemeViewDark.rawValue,
                                                                for : indexPath) as! ThemeCell
                
            case 2  : cell = collectionView.dequeueReusableCell(withReuseIdentifier : CellID.ThemeViewAzure.rawValue,
                                                                for : indexPath) as! ThemeCell
                
            case 3  : cell = collectionView.dequeueReusableCell(withReuseIdentifier : CellID.ThemeViewCrimson.rawValue,
                                                                for : indexPath) as! ThemeCell
            default : return UICollectionViewCell()
            }
            
            //fetch model
            let theme = calculator.themes[indexPath.item]
            
            //activate cell
            cell.activateTheme(withName : theme.name, selected : theme.selected.boolValue)

            return cell
        
        default :
            //prepare model
            var cell        : ItemCell
            var equation    : Equation
            let _indexPath  = (collectionView as! CollectionView).indexPath
            
            switch collectionView.tag
            {
            //equationList, recentList, manageList, groupEntityList, modelList (equationView)
            case 10, 20, 30, 40, 50 :
                
                //model
                equation = collectionView.tag == 10 ? calculator.currentEquations[_indexPath.row] :
                                                      calculator.equationSections[_indexPath.section][_indexPath.row]
                
                cell = self.itemCell(forEquation : equation, indexPath : indexPath, identifier :
                       CellID.EquationView.rawValue, collectionView : collectionView)
                
                return cell
            
            //modelList (modelView)
            case 60 :
                //init cell
                cell = collectionView.dequeueReusableCell(withReuseIdentifier : CellID.ModelView.rawValue,
                                                          for : indexPath) as! ItemCell
                
                switch calculator.selectedState
                {
                case .Equation, .SearchedEquation :
                    let targetEquation = calculator.selectedState == .Equation ?
                                         calculator.selectedEquation : calculator.selectedSearchedEquation
                    
                    if _indexPath.section == 0
                    {
                        if let holdingValue = DM.fetchValue(withEquationUID : targetEquation!.uid)
                        {
                            if let holdingEquation = DM.fetchEquation(forUID : holdingValue.belongTo)
                            {
                                return self.itemCell(forEquation : holdingEquation, indexPath : indexPath,
                                                     identifier : CellID.ModelView.rawValue,
                                                     collectionView : collectionView)
                            }
                            
                            cell.activate(value : holdingValue, collectionView : collectionView as! CollectionView)
                            return cell
                        }
                    }
                    return self.itemCell(forEquation : targetEquation!, indexPath : indexPath,
                                         identifier : CellID.ModelView.rawValue, collectionView : collectionView)
                    
                case .Value, .SearchedValue :
                    let targetValue = calculator.selectedState == .Value ?
                                      calculator.selectedValue : calculator.selectedSearchedValue
                    
                    if _indexPath.section == 0
                    {
                        if let holdingEquation = DM.fetchEquation(forUID : targetValue!.belongTo)
                        {
                            return self.itemCell(forEquation : holdingEquation, indexPath : indexPath,
                                                 identifier : CellID.ModelView.rawValue,
                                                 collectionView : collectionView)
                        }
                    }
                    else if let subEquation = DM.fetchEquation(forUID : targetValue!.uid)
                    {
                        return self.itemCell(forEquation : subEquation, indexPath : indexPath,
                                             identifier : CellID.ModelView.rawValue, collectionView : collectionView)
                    }
                    
                    cell.activate(value : targetValue!, collectionView : collectionView as! CollectionView)
                    return cell
                    
                default : return cell
                }
            
            //metaList (tagView)
            case 70 :
                //init cell
                cell = collectionView.dequeueReusableCell(withReuseIdentifier : CellID.TagView.rawValue,
                                                          for : indexPath) as! ItemCell
                var tag : Tag?
                
                if calculator.valueField.isFirstResponder
                {
                    switch calculator.fieldState
                    {
                    case .CreateEquation, .CreateValue, .EditEquation, .EditValue :
                        tag = calculator.entityTags[indexPath.item]
                    default : break
                    }
                }
                else
                {
                    //case
                    switch calculator.selectedState
                    {
                    case .Equation          : tag = calculator.selectedEquation!.fetchTags()[indexPath.item]
                    case .SearchedEquation  : tag = calculator.selectedSearchedEquation!.fetchTags()[indexPath.item]
                    case .Value             : tag = calculator.selectedValue!.fetchTags()[indexPath.item]
                    case .SearchedValue     : tag = calculator.selectedSearchedValue!.fetchTags()[indexPath.item]
                    default                 : break
                    }
                }

                //activate
                cell.activate(tag : tag!)
                
                return cell
                
            //entityView
            case 80 :
                cell = collectionView.dequeueReusableCell(withReuseIdentifier : CellID.EntityView.rawValue,
                                                          for : indexPath) as! ItemCell

                //activate
                let state = calculator.fieldState
                cell.activate(entityName : calculator.valueField.text!, entityValue : calculator.entityValueStr, state : state)
                
                return cell
            
            default : return UICollectionViewCell()
            }

        }
    }
    
    
    //MARK: - UICollectionView Delegate
    
    
    func collectionView(_ collectionView : UICollectionView, didSelectItemAt indexPath : IndexPath)
    {
        //prevent auto-registration of indexPathsForSelectedItems
        calculator.operationView.deselectItem(at : indexPath, animated : false)
        calculator.searchView.deselectItem(at : indexPath, animated : false)
        calculator.themeView.deselectItem(at : indexPath, animated : false)
        
        switch collectionView
        {
        case calculator.operationView :
        
            /* fetch model (bifurcate) */
            
            //value
            if indexPath.item % 2 == 0
            {
                //prepare index
                let index = indexPath.item / 2
                
                //validate
                if calculator.currentEquation == calculator.highlightedEquation || calculator.currentEquation == calculator.selectedEquation || calculator.selectedValue != nil || calculator.selectedOperation != nil
                {
                    //set control to calculator
                    calculator.controlState = .Calculator
                    calculator.refreshControl()
                    
                    //activate calKey switch
                    calculator.control.enable(controls : [.Calculator, .Keyboard])
                }
                
                //fetch target model
                let value = calculator.currentEquation!.fetchValues()[index]
                
                //select value
                if value == calculator.highlightedValue
                {
                    //validate
                    if calculator.currentEquation == calculator.wrongEquation
                    {
                        return
                    }
                    
                    //select value
                    SM.adjustSelection(withState : .Value)
                    
                    value.select()
                    
                    calculator.control.layout(cancel : .Value)
                    
                    calculator.selectFrom = .Operation
                    calculator.selectionView.value(selectFrom : calculator.selectFrom)
                    calculator.equationField.inputView = calculator.selectionView
                    calculator.equationField.reloadInputViews()
                    
                    //display infoView
                    calculator.infoView.show()
                    
                    //prepare offset
                    self.operationSelected  = true
                    self.operationOffset    = calculator.operationView.contentOffset
                }
                //highlight value
                else
                {
                    //update
                    calculator.valueBeforeEquation        = value
                    calculator.operationBeforeEquation    = nil
                    
                    value.highlight()
                }
            }
            //operation
            else
            {
                //prepare index
                let index = (indexPath.item - 1) / 2
                
                //validate
                if calculator.currentEquation == calculator.highlightedEquation || calculator.currentEquation == calculator.selectedEquation || calculator.selectedOperation != nil || calculator.selectedValue != nil
                {
                    //set control to calculator
                    calculator.controlState = .Calculator
                    calculator.refreshControl()
                    
                    //activate calKey switch
                    calculator.control.enable(controls : [.Calculator, .Keyboard])
                }
                
                //fetch target model
                let operation = calculator.currentEquation!.fetchOperations()[index]
                
                //highlight operation
                if operation != calculator.highlightedOperation
                {
                    //update
                    calculator.valueBeforeEquation        = nil
                    calculator.operationBeforeEquation    = operation
                    
                    operation.highlight()
                }
            }
            
            //reload
            calculator.unitList.reloadData()
        
        case calculator.searchView :
            if indexPath.section == 0
            {
                //fetch target model
                let searchedEquation = calculator.searchedEquations[indexPath.item]
                
                //select searchedEquation
                SM.adjustSelection(withState : .Equation)
                
                //select
                calculator.selectedSearchedEquation = searchedEquation
                calculator.selectedState            = .SearchedEquation
                
                searchedEquation.hit()
                
                //update date
                calculator.selectedSearchedEquation?.recentDate = Date()
                
                //display infoView
                calculator.infoView.show()
                
                //validate
                if let selectedValue = calculator.selectedValue
                {
                    if calculator.searchedValues.contains(selectedValue)
                    {
                        calculator.selectedValue = nil
                    }
                }
                
                calculator.control.layout(cancel : .SearchedEquation)
                
                calculator.selectFrom = .Search
                calculator.selectionView.equation(selectFrom : calculator.selectFrom)
                calculator.equationField.inputView = calculator.selectionView
                calculator.equationField.reloadInputViews()
                
                //prepare offset
                self.searchSelected = true
                self.searchOffset = calculator.searchView.contentOffset
            }
            else
            {
                //fetch target model
                let searchedValue = calculator.searchedValues[indexPath.item]
                
                //select searchedValue
                SM.adjustSelection(withState : .Value)
                
                //select
                calculator.selectedSearchedValue    = searchedValue
                calculator.selectedState            = .SearchedValue
                
                searchedValue.hit()
                
                //update date
                calculator.selectedSearchedValue?.recentDate = Date()
                
                //display infoView
                calculator.infoView.show()
                
                //validate
                if let selectedEquation = calculator.selectedEquation
                {
                    if calculator.searchedEquations.contains(selectedEquation)
                    {
                        calculator.selectedEquation = nil
                    }
                }
                
                calculator.control.layout(cancel : .SearchedValue)
                
                calculator.selectFrom = .Search
                calculator.selectionView.value(selectFrom : calculator.selectFrom)
                calculator.equationField.inputView = calculator.selectionView
                calculator.equationField.reloadInputViews()
                
                //prepare offset
                self.searchSelected = true
                self.searchOffset = calculator.searchView.contentOffset
            }
            
            //reload
            calculator.unitList.reloadData()
        
        case calculator.themeView :
            let theme = calculator.themes[indexPath.item]
        
            if theme.selected == false
            {
                theme.selected = true
                calculator.selectedTheme = theme
                
                //de-select other themes
                for _theme in calculator.themes
                {
                    if _theme != theme
                    {
                        _theme.selected = false
                    }
                }
                
                //save
                DM.saveContext()
                
                //apply changes
                calculator.themeView.reloadData()
                SM.updateTheme()
            }
            else
            {
                return
            }
        
        default :
            //prepare
            let _indexPath = (collectionView as! CollectionView).indexPath
            
            switch collectionView.tag
            {
            //equationList
            case 10 :
                calculator.currentEquation = calculator.currentEquations[_indexPath.row]
                calculator.currentEquation!.lastValue()?.highlight()
                
                //reload
                calculator.calculate(equation : calculator.currentEquation!)
                calculator.equationView.updateCount()
                
                //update date
                calculator.currentEquation!.recentDate = Date()
                
                //animate
                UIView.animate(withDuration : 0.3, animations :
                {
                    calculator.searchView.alpha         = 1
                    calculator.blurView.alpha           = 0.0
                    calculator.equationList.alpha       = 0.0
                    
                    //update statusBar
                    SM.updateStatusBar()
                        
                }, completion : { (finished) in
                    
                    calculator.blurView.removeFromSuperview()
                    calculator.equationView.isUserInteractionEnabled = true
                    calculator.operationView.isUserInteractionEnabled = true
                    calculator.searchView.isUserInteractionEnabled = true
                })
                
                calculator.equationField.becomeFirstResponder()
            
            //recentList, groupEntityList
            case 20, 30 :
                let equation = calculator.equationSections[_indexPath.section][_indexPath.row]
                self.itemSelected(forEquation : equation, indexPath : indexPath, collectionView : collectionView)
                
                return
            
            //manageList
            case 40 :
                let equation = calculator.equationSections[_indexPath.section][_indexPath.row]
                
                if calculator.manageEditing
                {
                    if calculator.selectedEquations.contains(equation)
                    {
                        calculator.selectedEquations.remove(at : calculator.selectedEquations.index(of : equation)!)
                    }
                    else
                    {
                        calculator.selectedEquations.append(equation)
                    }
                    
                    //reload selected
                    calculator.manageList.reloadRows(at : [_indexPath], with : .none)
                    
                    //update
                    calculator.manageVC!.updateSelectedCount()
                }
                else
                {
                    //select
                    self.itemSelected(forEquation : equation, indexPath : indexPath, collectionView : collectionView)
                    
                    calculator.equationField.becomeFirstResponder()
                }
            
            //modelList (tag)
            case 50 :
                if calculator.entityState == .EntityEquation
                {
                    let equation = calculator.equationSections[_indexPath.section][_indexPath.row]
                    self.itemSelected(forEquation : equation, indexPath : indexPath, collectionView : collectionView)
                    return
                }
                
            //modelList (equation, value)
            case 60 :
                switch calculator.selectedState
                {
                case .Equation, .SearchedEquation :
                    let targetEquation = calculator.selectedState == .Equation ?
                                         calculator.selectedEquation : calculator.selectedSearchedEquation
                    
                    if _indexPath.section == 0
                    {
                        if let holdingValue = DM.fetchValue(withEquationUID : targetEquation!.uid)
                        {
                            if let holdingEquation = DM.fetchEquation(forUID : holdingValue.belongTo)
                            {
                                self.itemSelected(forEquation : holdingEquation, indexPath : indexPath,
                                                  collectionView : collectionView)
                                return
                            }
                            self.itemSelected(forValue : holdingValue)
                            return
                        }
                    }
                    self.itemSelected(forEquation : targetEquation!, indexPath : indexPath,
                                      collectionView : collectionView)
                    return
                    
                case .Value, .SearchedValue :
                    let targetValue = calculator.selectedState == .Value ?
                                      calculator.selectedValue : calculator.selectedSearchedValue
                    
                    if _indexPath.section == 0
                    {
                        if let holdingEquation = DM.fetchEquation(forUID : targetValue!.belongTo)
                        {
                            self.itemSelected(forEquation : holdingEquation, indexPath : indexPath,
                                              collectionView : collectionView)
                            return
                        }
                    }
                    else if let subEquation = DM.fetchEquation(forUID : targetValue!.uid)
                    {
                        self.itemSelected(forEquation : subEquation, indexPath : indexPath,
                                          collectionView : collectionView)
                        return
                    }
                    self.itemSelected(forValue : targetValue!)
                    return
                    
                default : return
                }
                
            //metaList (tagView)
            case 70 :
                if calculator.fieldState != .None
                {
                    return
                }
                
                //adjust selectionView
                SM.adjustSelection(withState : .Tag)
                
                //case
                switch calculator.selectedState
                {
                case .Equation          : calculator.selectedEquation!.fetchTags()[indexPath.item].select()
                case .SearchedEquation  : calculator.selectedSearchedEquation!.fetchTags()[indexPath.item].select()
                case .Value             : calculator.selectedValue!.fetchTags()[indexPath.item].select()
                case .SearchedValue     : calculator.selectedSearchedValue!.fetchTags()[indexPath.item].select()
                default                 : break
                }
                
                calculator.control.layout(cancel : .Tag)
                calculator.selectionView.listTag()
                
                //reload
                calculator.equationField.inputView = calculator.selectionView
                calculator.equationField.reloadInputViews()
                
                //display infoView
                calculator.infoView.show()
            
            default : return
            }

        }
    }
    
    @objc func didSelectEquation(withTapGesture tapGesture : UITapGestureRecognizer)
    {
        let collectionView = tapGesture.view?.superview as! CollectionView
        switch collectionView.tag
        {
        //equationList
        case 10 : self.tableView(calculator.equationList, didSelectRowAt : collectionView.indexPath)
            
        //recentList
        case 20 : self.tableView(calculator.recentList, didSelectRowAt : collectionView.indexPath)
            
        //groupEntityList
        case 30 : self.tableView(calculator.groupEntityList, didSelectRowAt : collectionView.indexPath)
            
        //manageList
        case 40 : self.tableView(calculator.manageList, didSelectRowAt : collectionView.indexPath)
            
        //modelList
        case 50 : self.tableView(calculator.modelList, didSelectRowAt : collectionView.indexPath)
            
        default : return
        }
        
    }
    
    
    //MARK: - UITableView DataSource
    
    
    func numberOfSections(in tableView : UITableView) -> Int
    {
        switch tableView
        {
        case calculator.equationList    : return 1
        case calculator.modelList       :
            switch calculator.selectedState
            {
            case .Equation, .SearchedEquation :
                let targetEquation = calculator.selectedState == .Equation ?
                                     calculator.selectedEquation : calculator.selectedSearchedEquation
                
                return DM.fetchValue(withEquationUID : targetEquation!.uid) != nil ? 2 : 1
                
            case .Value, .SearchedValue :
                let targetValue = calculator.selectedState == .Value ?
                                  calculator.selectedValue : calculator.selectedSearchedValue
                
                return DM.fetchEquation(forUID : targetValue!.belongTo) != nil ||
                       targetValue!.isEquation.boolValue ? 2 : 1
                
            default :
                if calculator.entityState == .EntityEquation
                {
                    return calculator.equationSections.count == 0 ? 1 : calculator.equationSections.count
                }
                else
                {
                    return calculator.valueSections.count == 0 ? 1 : calculator.valueSections.count
                }
                
            }
        
        case calculator.metaList : return 1
        case calculator.recentList :
            switch calculator.recentState
            {
            case .RecentEquation    : return calculator.equationSections.count
            case .RecentValue       : return calculator.valueSections.count
            default                 : return 0
            }
        
        case calculator.filterList : return 1
        case calculator.manageList :
            switch calculator.entityState
            {
            case .EntityGroup       : return calculator.groupSections.count
            case .EntityEquation    : return calculator.equationSections.count
            case .EntityValue       : return calculator.valueSections.count
            case .EntityTag         : return calculator.tagSections.count
            default                 : return 0
            }
        
        case calculator.groupList :
            if calculator.operationState == .GroupSelect
            {
                return calculator.groupSections.count != 0 ? calculator.groupSections.count : 1
            }
            else if calculator.manageEditing
            {
                return calculator.groupSections.count + 1
            }
            else
            {
                return calculator.groupSections.count != 0 ? calculator.groupSections.count : 0
            }
            
        case calculator.groupEntityList :
            switch calculator.groupState
            {
            case .GroupEquation : return calculator.equationSections.count
            case .GroupValue    : return calculator.valueSections.count
            case .GroupTag      : return calculator.tagSections.count
            default             : return 0
            }
        
        case calculator.tagList :
            if calculator.operationState == .TagSelect
            {
                return calculator.tagSections.count != 0 ? calculator.tagSections.count : 1
            }
            else
            {
                return calculator.tagSections.count != 0 ? calculator.tagSections.count : 0
            }
            
        case calculator.unitGroupList   : return 1
        case calculator.unitList        : return 1
        case calculator.unitPickerList  : return calculator.selectedUnitGroup!.name == "#currency".local ?
                                                 calculator.currencySections.count : 1
        
        case calculator.settingList         : return self.settingTitles.count
        case calculator.settingDepthList    :
            switch calculator.settingState
            {
            case .Settings  : return self.settingDepthItems.count
            case .Support   : return self.supportDepthItems.count
            default         : return 1
            }
            
        case calculator.settingInDepthList  : return 1
        case calculator.selectionList       : return 2
        default                             : return 0
        }
    }
    
    func tableView(_ tableView : UITableView, numberOfRowsInSection section : Int) -> Int
    {
        switch tableView
        {
        case calculator.equationList    : return calculator.currentEquations.count
        case calculator.modelList       :
            switch calculator.selectedState
            {
            case .Equation, .SearchedEquation, .Value, .SearchedValue : return 1
            default :
                if calculator.entityState == .EntityEquation
                {
                    return calculator.equationSections.indices.contains(section) ?
                           calculator.equationSections[section].count : 0
                }
                else
                {
                    return calculator.valueSections.indices.contains(section) ?
                           calculator.valueSections[section].count : 0
                }
            }

        case calculator.metaList :
            if calculator.valueField.isFirstResponder && calculator.viewState != .ManageSearch
            {
                switch calculator.fieldState
                {
                case .CreateEquation, .EditEquation, .CreateValue, .EditValue   : return 3
                default                                                         : return 0
                }
            }

            //info
            switch calculator.selectedState
            {
            case .Equation, .SearchedEquation, .Value, .SearchedValue   : return 4
            default                                                     : return 1
            }
            
        case calculator.recentList :
            switch calculator.recentState
            {
            case .RecentEquation    : return calculator.equationSections[section].count
            case .RecentValue       : return calculator.valueSections[section].count
            default                 : return 0
            }
        
        case calculator.filterList : return calculator.filters.count
        case calculator.manageList :
            switch calculator.entityState
            {
            case .EntityGroup       : return calculator.groupSections[section].count
            case .EntityEquation    : return calculator.equationSections[section].count
            case .EntityValue       : return calculator.valueSections[section].count
            case .EntityTag         : return calculator.tagSections[section].count
            default                 : return 0
            }
        
        case calculator.groupList :
            if calculator.manageEditing
            {
                return section == 0 ? 1 : calculator.groupSections[section - 1].count
            }
            return calculator.groupSections.indices.contains(section) ? calculator.groupSections[section].count : 0
        
        case calculator.groupEntityList :
            switch calculator.groupState
            {
            case .GroupEquation : return calculator.equationSections[section].count
            case .GroupValue    : return calculator.valueSections[section].count
            case .GroupTag      : return calculator.tagSections[section].count
            default             : return 0
            }

        case calculator.tagList :
            return calculator.tagSections.indices.contains(section) ? calculator.tagSections[section].count : 0
            
        case calculator.unitGroupList       : return calculator.unitGroups.count
        case calculator.unitList            : return calculator.selectedUnits.count
        case calculator.unitPickerList      : return calculator.selectedUnitGroup!.name == "#currency".local ?
                                                     calculator.currencySections[section].count :
                                                     calculator.selectedUnitGroup!.fetchUnits().count
        
        case calculator.settingList         : return self.settingTitles[section].count
        case calculator.settingDepthList    :
            switch calculator.settingState
            {
            case .Version   : return 1
            case .Settings  : return self.settingDepthItems[section].count
            case .Support   : return self.supportDepthItems[section].count
            case .Legal     : return self.legalDepthItems.count
            default         : return 0
            }
            
        case calculator.settingInDepthList  : return calculator.fonts.count
        case calculator.selectionList       : return section == 0 ? calculator.selectionTitles.count : 1
        default                             : return 0
        }
    }
    
    func tableView(_ tableView : UITableView, cellForRowAt indexPath : IndexPath) -> UITableViewCell
    {
        switch tableView
        {
        case calculator.equationList :
            let cell = tableView.dequeueReusableCell(withIdentifier : CellID.EquationList.rawValue) as! EquationCell
        
            let equation = calculator.currentEquations[indexPath.row]
            cell.activate(equation : equation, listView : calculator.equationList, indexPath : indexPath)
        
            return cell
        
        case calculator.modelList :
            switch calculator.selectedState
            {
            case .Equation, .SearchedEquation, .Value, .SearchedValue :
                return indexPath.section == 0 ? calculator.upperModelCell! : calculator.lowerModelCell!
                
            default :
                if calculator.entityState == .EntityEquation
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier : CellID.ModelListE.rawValue)
                        as! EquationCell
                    
                    let equation = calculator.equationSections[indexPath.section][indexPath.row]
                    cell.activate(equation : equation, listView : calculator.modelList, indexPath : indexPath)
                    
                    return cell
                }
                else
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier : CellID.ModelListV.rawValue)
                        as! EntityCell
                    
                    let value = calculator.valueSections[indexPath.section][indexPath.row]
                    cell.activate(value : value, listView : calculator.modelList, indexPath : indexPath)
                    
                    return cell
                }
            }
        
        case calculator.metaList :
            //case
            if calculator.valueField.isFirstResponder
            {
                let cell = tableView.dequeueReusableCell(withIdentifier : CellID.MetaListE.rawValue) as! MetaCell
                
                switch calculator.fieldState
                {
                case .CreateEquation, .EditEquation, .CreateValue, .EditValue :
                    switch indexPath.row
                    {
                    case 0  : cell.activate(state : .Group, indexPath : indexPath)
                    case 1  : cell.activate(state : .Unit, indexPath : indexPath)
                    case 2  : cell.activate(state : .Tag, indexPath : indexPath)
                    default : break
                    }
                    return cell
                    
                default : return cell
                }
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier : CellID.MetaListI.rawValue) as! MetaCell
                
                switch calculator.selectedState
                {
                case .Equation, .SearchedEquation, .Value, .SearchedValue :
                    switch indexPath.row
                    {
                    case 0  : cell.activate(state : .Group, indexPath : indexPath)
                    case 1  : cell.activate(state : .Unit, indexPath : indexPath)
                    case 2  : cell.activate(state : .Date, indexPath : indexPath)
                    case 3  : cell.activate(state : .Tag, indexPath : indexPath)
                    default : break
                    }
                    return cell
                    
                default :
                    cell.activate(state : .EntityTag, indexPath : indexPath)
                    return cell
                }
                
            }
        
        case calculator.recentList :
            switch calculator.recentState
            {
            case .RecentEquation :
                let cell = tableView.dequeueReusableCell(withIdentifier : CellID.RecentListE.rawValue) as! EquationCell
                
                let equation = calculator.equationSections[indexPath.section][indexPath.row]
                cell.activate(equation : equation, listView : calculator.recentList, indexPath : indexPath)
                
                return cell
            
            case .RecentValue :
                let cell = tableView.dequeueReusableCell(withIdentifier : CellID.RecentListV.rawValue) as! EntityCell
                
                let value = calculator.valueSections[indexPath.section][indexPath.row]
                cell.activate(value : value, listView : calculator.recentList, indexPath : indexPath)
                
                return cell
            
            default : return UITableViewCell()
            }
        
        case calculator.filterList :
            let cell = tableView.dequeueReusableCell(withIdentifier : CellID.FilterList.rawValue) as! EntityCell
            
            let filter = calculator.filters[indexPath.row]
            cell.activate(filter : filter)
            
            return cell
        
        case calculator.manageList :
            switch calculator.entityState
            {
            case .EntityGroup :
                let cell = tableView.dequeueReusableCell(withIdentifier : CellID.ManageListG.rawValue) as! EntityCell
                
                //fetch model
                let group = calculator.groupSections[indexPath.section][indexPath.row]
                cell.activate(group : group, listView : calculator.manageList, indexPath : indexPath)
                
                return cell
            
            case .EntityEquation :
                let cell = tableView.dequeueReusableCell(withIdentifier : CellID.ManageListE.rawValue) as! EquationCell
                
                //fetch model
                let equation = calculator.equationSections[indexPath.section][indexPath.row]
                cell.activate(equation : equation, listView : calculator.manageList, indexPath : indexPath)
                
                return cell
            
            case .EntityValue :
                let cell = tableView.dequeueReusableCell(withIdentifier : CellID.ManageListV.rawValue) as! EntityCell
                
                //fetch model
                let value = calculator.valueSections[indexPath.section][indexPath.row]
                cell.activate(value : value, listView : calculator.manageList, indexPath : indexPath)
                
                return cell
            
            case .EntityTag :
                let cell = tableView.dequeueReusableCell(withIdentifier : CellID.ManageListT.rawValue) as! EntityCell
                
                //fetch model
                let tag = calculator.tagSections[indexPath.section][indexPath.row]
                cell.activate(tag : tag, listView : calculator.manageList, indexPath : indexPath)
                
                return cell
            
            default : return UITableViewCell()
            }
        
        case calculator.groupList :
            if calculator.manageEditing
            {
                if indexPath.section == 0
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier : CellID.GroupListNone.rawValue) as! EntityCell
                    
                    cell.activateGroupNone()
                    return cell
                }
                else
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier : CellID.GroupList.rawValue) as! EntityCell
                    let group = calculator.groupSections[indexPath.section - 1][indexPath.row]
                    
                    cell.activate(group : group, listView : calculator.groupList, indexPath : indexPath)
                    return cell
                }
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier : CellID.GroupList.rawValue) as! EntityCell
                let group = calculator.groupSections[indexPath.section][indexPath.row]
                
                cell.activate(group : group, listView : calculator.groupList, indexPath : indexPath)
                return cell
            }
            
        case calculator.groupEntityList :
            switch calculator.groupState
            {
            case .GroupEquation :
                let cell = tableView.dequeueReusableCell(withIdentifier : CellID.GroupEntityListE.rawValue) as! EquationCell
                
                let equation = calculator.equationSections[indexPath.section][indexPath.row]
                cell.activate(equation : equation, listView : calculator.groupEntityList, indexPath : indexPath)
                
                return cell
            
            case .GroupValue :
                let cell = tableView.dequeueReusableCell(withIdentifier : CellID.GroupEntityListV.rawValue) as! EntityCell
                
                let value = calculator.valueSections[indexPath.section][indexPath.row]
                cell.activate(value : value, listView : calculator.groupEntityList, indexPath : indexPath)
                
                return cell
            
            case .GroupTag :
                let cell = tableView.dequeueReusableCell(withIdentifier : CellID.GroupEntityListT.rawValue) as! EntityCell
                
                let tag = calculator.tagSections[indexPath.section][indexPath.row]
                cell.activate(tag : tag, listView : calculator.groupEntityList, indexPath : indexPath)
                
                return cell
            
            default : return UITableViewCell()
            }
        
        case calculator.tagList :
            let cell = tableView.dequeueReusableCell(withIdentifier : CellID.TagList.rawValue) as! EntityCell
            
            let tag = calculator.tagSections[indexPath.section][indexPath.row]
            cell.activate(tag : tag, listView : calculator.tagList, indexPath : indexPath)
            
            return cell
        
        case calculator.unitGroupList :
            let cell = tableView.dequeueReusableCell(withIdentifier : CellID.UnitGroupList.rawValue) as! EntityCell
            
            let unitGroup = calculator.unitGroups[indexPath.row]
            cell.activate(unitGroup : unitGroup)
            
            return cell
        
        case calculator.unitList :
            let cell = tableView.dequeueReusableCell(withIdentifier : CellID.UnitList.rawValue) as! EntityCell
            let unit = calculator.selectedUnits[indexPath.row]
            
            cell.activate(unit : unit, listView : calculator.unitList, indexPath : indexPath)
            return cell
        
        case calculator.unitPickerList :
            let cell = tableView.dequeueReusableCell(withIdentifier : CellID.UnitPickerList.rawValue) as! EntityCell
            
            if calculator.selectedUnitGroup!.name == "#currency".local
            {
                let unit = calculator.currencySections[indexPath.section][indexPath.row]
                cell.activate(unit : unit, listView : calculator.unitPickerList, indexPath : indexPath)
                return cell
            }
            
            let unit = calculator.selectedUnitGroup!.fetchUnits()[indexPath.row]
            cell.activate(unit : unit, listView : calculator.unitPickerList, indexPath : indexPath)
            return cell
        
        case calculator.settingList :
            let cell = tableView.dequeueReusableCell(withIdentifier : CellID.SettingList.rawValue) as! SettingCell
            
            let title = self.settingTitles[indexPath.section][indexPath.row]
            let detailed = self.detailedSettings.contains(indexPath) ? true : false
            
            switch title
            {
            case "S1.reset".local :
                cell.activate(withIcon : nil, title : title, detailed : detailed, indexPath : indexPath)
                
            default :
                let icon = self.settingIcons[indexPath.section][indexPath.row]
                cell.activate(withIcon : icon, title : title, detailed : detailed, indexPath : indexPath)
                
            }
        
            return cell
        
        case calculator.settingDepthList :
            let cell = tableView.dequeueReusableCell(withIdentifier : CellID.SettingDepthList.rawValue) as! SettingCell
            var title : String?

            switch calculator.settingState
            {
            case .Version   : title = "\("S1.version".local) 1.0"
            case .Settings  :
                title       = self.settingDepthItems[indexPath.section][indexPath.row]
                let setting = calculator.setting!
                
                //activate basic
                if indexPath.section == 0
                {
                    switch title!
                    {
                    case "S2-1-1.english".local :
                        cell.activateSwitch(withIcon : nil, title : title!, toggled : setting.showEnglish.boolValue, indexPath : indexPath)
                        
                    case "S2-1-1.sound".local :
                        cell.activateSwitch(withIcon : nil, title : title!, toggled : setting.playSound.boolValue, indexPath : indexPath)
                        
                    case "S2-1-1.autoSave".local :
                        cell.activateSwitch(withIcon : nil, title : title!, toggled : setting.resetAutoSave.boolValue, indexPath : indexPath)
                        
                    case "S2-1-1.decimal".local :
                        cell.activateStepper(withTitle : title!)
                        
                    default : return cell
                    }
                }
                else
                {
                    cell.activate(withIcon : nil, title : title!, detailed : true, indexPath : indexPath)
                }
                return cell
            
            case .Support   : title = self.supportDepthItems[indexPath.section][indexPath.row]
            case .Legal     : title = self.legalDepthItems[indexPath.row]
            default         : return cell
            }
            
            cell.activate(withIcon : nil, title : title!, detailed : false, indexPath : indexPath)
            return cell
        
        case calculator.settingInDepthList :
            let cell = tableView.dequeueReusableCell(withIdentifier : CellID.SettingInDepthList.rawValue) as! SettingCell
            
            //fetch font
            let font = calculator.fonts[indexPath.row]
            
            //activate cell
            cell.activateCheck(withTitle : font.name, selected : font.selected.boolValue, indexPath : indexPath)
            
            return cell
        
        case calculator.selectionList :
            let cell = tableView.dequeueReusableCell(withIdentifier : CellID.SelectionList.rawValue) as! SelectionCell
            
            if indexPath.section == 0
            {
                let title = calculator.selectionTitles[indexPath.row]
                cell.activate(withTitle : title)
            }
            else
            {
                cell.activate(withTitle : "#cancel".local)
            }
            
            return cell
        
        default : return UITableViewCell()
        }
    }
    
    func tableView(_ tableView : UITableView, shouldHighlightRowAt indexPath : IndexPath) -> Bool
    {
        switch tableView
        {
        case calculator.settingList      : return true
        case calculator.settingDepthList :
            switch calculator.settingState
            {
            case .Version   : return false
            case .Settings  :
                switch (indexPath.section, indexPath.row)
                {
                case (0, 0), (0, 1), (0, 2) : return false
                default                     : return true
                }
                
            case .Support   : return true
            case .Legal     : return true
            default         : return false
            }
            
        case calculator.metaList : return false
        default : return true
        }
    }
    
    func tableView(_ tableView : UITableView, heightForRowAt indexPath : IndexPath) -> CGFloat
    {
        switch tableView
        {
        case calculator.equationList, calculator.recentList, calculator.groupList,
             calculator.groupEntityList, calculator.tagList :
            return cellHeight
            
        case calculator.modelList :
            //case
            switch calculator.selectedState
            {
            case .Equation, .SearchedEquation, .Value, .SearchedValue :
                if calculator.modelList.numberOfSections == 2
                {
                    return indexPath.section == 0 ? calculator.upperModelCell!.bounds.height :
                                                    calculator.lowerModelCell!.bounds.height
                }
                else
                {
                    return calculator.upperModelCell!.bounds.height
                }
                
            default :
                return cellHeight
                
            }
        
        case calculator.metaList :
            if calculator.valueField.isFirstResponder
            {
                switch calculator.fieldState
                {
                case .CreateEquation, .EditEquation, .CreateValue, .EditValue :
                    return (calculator.metaList.bounds.height - 25) / 3

                default : return 0
                }
            }
            
            switch calculator.selectedState
            {
            case .Equation, .SearchedEquation, .Value, .SearchedValue   : return (calculator.metaList.bounds.height - 25) / 4
            default                                                     : return calculator.metaList.bounds.height - 25
            }
            
        case calculator.unitGroupList, calculator.unitList :
            return isBigFont ? cellHeight : (btnLength * 4) / CGFloat(calculator.unitGroups.count)
            
        case calculator.filterList :
            let filterCount = CGFloat(calculator.filters.count)
            return isIphoneX ? ((btnLength * 4) + (bottomBuffer - ctrlBtnHeight - homeBuffer)) * 0.85 / filterCount :
                               ((btnLength * 4) - ctrlBtnHeight) * 0.85 / filterCount
        
        default : return cellHeight
        }
    }
    
    func tableView(_ tableView : UITableView, heightForHeaderInSection section : Int) -> CGFloat
    {
        switch tableView
        {
        case calculator.equationList    : return 60
        case calculator.modelList       :
            switch calculator.selectedState
            {
            case .Equation, .SearchedEquation, .Value, .SearchedValue : return 25
            default                 :
                if calculator.entityState == .EntityEquation
                {
                    return calculator.equationSections.count != 0 ? 0.01 : calculator.modelList.bounds.height
                }
                else
                {
                    return calculator.valueSections.count != 0 ? 0.01 : calculator.modelList.bounds.height
                }
                
            }
            
        case calculator.metaList    : return 25
        case calculator.recentList  :
            switch calculator.recentState
            {
            case .RecentEquation    : return calculator.equationSections.count != 0 ? 30 : 0.01
            case .RecentValue       : return calculator.valueSections.count != 0    ? 30 : 0.01
            default                 : return 0.01
            }
        
        case calculator.manageList :
            switch calculator.entityState
            {
            case .EntityGroup       : return calculator.groupSections.count != 0    ? 30 : 0.01
            case .EntityEquation    : return calculator.equationSections.count != 0 ? 30 : 0.01
            case .EntityValue       : return calculator.valueSections.count != 0    ? 30 : 0.01
            case .EntityTag         : return calculator.tagSections.count != 0      ? 30 : 0.01
            default                 : return 0.01
            }
        
        case calculator.groupList :
            if calculator.operationState == .GroupSelect
            {
                return calculator.groupSections.count != 0 ? 30 : btnLength * 3
            }
            else if calculator.manageEditing
            {
                return section == 0 ? calculator.manageVC!.topBar.bounds.height : 0.01
            }
            return 0.01
        
        case calculator.tagList :
            if calculator.operationState == .TagSelect
            {
                return calculator.tagSections.count != 0 ? 30 : btnLength * 3
            }
            return 30
            
        case calculator.unitPickerList      : return calculator.selectedUnitGroup!.name == "#currency".local ? 30 : 0.01
        case calculator.settingList         : return 30
        case calculator.settingDepthList    : return calculator.settingState == .Settings ? 60 : 30
//        case calculator.settingInDepthList  : return 10
        case calculator.selectionList       : return section == 0 ? calculator.selectionListState == .EquationList ?
                                                     0.01 : 50 : 30
        default                             : return 0.01
        }
    }
    
    func tableView(_ tableView : UITableView, heightForFooterInSection section : Int) -> CGFloat
    {
        switch tableView
        {
        case calculator.settingList         : return section == 4 ? 120 : 0.01
        case calculator.settingDepthList    :
            switch calculator.settingState
            {
            case .Settings  : return 20
            case .Support   : return 60
            default         : return 30
            }
        
        case calculator.settingInDepthList  : return 44
        case calculator.selectionList       : return section == 0 ? calculator.selectionListState == .EquationList ?
                                                     0.01 : 0.1 : 30
        default                             : return 0.01
        }
    }
    
    func tableView(_ tableView : UITableView, viewForHeaderInSection section : Int) -> UIView?
    {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier : "header") as! Header
        header.activate(tableView : tableView, section : section)
        
        return header
    }
    
    func tableView(_ tableView : UITableView, viewForFooterInSection section : Int) -> UIView?
    {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier : "footer") as! Footer
        footer.activate(tableView : tableView, section : section)
        
        return footer
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    {
        switch tableView
        {
        case calculator.unitList        : return "#hide".local
        default                         : return "#delete".local
        }
    }
    
    func sectionIndexTitles(for tableView : UITableView) -> [String]?
    {
        switch tableView
        {
        case calculator.recentList, calculator.groupEntityList, calculator.tagList :
            return calculator.entityIndexTitles
        
        case calculator.groupList :
            return calculator.manageDisplayed ? calculator.entityIndexTitles : calculator.sectionIndexTitles
        
        case calculator.unitPickerList :
            return calculator.selectedUnitGroup!.name == "#currency".local ? calculator.sectionIndexTitles : nil
        
        case calculator.manageList :
            return calculator.sectionIndexTitles
            
        case calculator.modelList :
            return calculator.selectedState == .Tag ? calculator.sectionIndexTitles : nil
        
        default : return nil
        }
    }
    
    func tableView(_ tableView : UITableView, sectionForSectionIndexTitle title : String, at index : Int) -> Int
    {
        switch tableView
        {
        case calculator.recentList, calculator.groupEntityList, calculator.tagList :
            return calculator.entityIndexTitles.index(of : title)!
            
        case calculator.groupList :
            return calculator.manageDisplayed ? calculator.entityIndexTitles.index(of : title)! :
                   calculator.sectionIndexTitles.index(of : title)!
    
        case calculator.unitPickerList :
            return calculator.selectedUnitGroup!.name == "#currency".local ? calculator.sectionIndexTitles.index(of : title)! : 0
        
        case calculator.manageList :
            return calculator.sectionIndexTitles.index(of : title)!
            
        case calculator.modelList :
            return calculator.selectedState == .Tag ? calculator.sectionIndexTitles.index(of : title)! : 0
        
        default : return 0
        }
    }
    
    
    //MARK: - UITableView Delegate
    
    
    func tableView(_ tableView : UITableView, didSelectRowAt indexPath : IndexPath)
    {
        switch tableView
        {
        case calculator.equationList :
            //fetch model
            let selectedEquation = calculator.currentEquations[indexPath.row]
            calculator.currentEquation = selectedEquation
            
            //highlight last value
            calculator.currentEquation!.lastValue()!.highlight()
        
            //reload
            calculator.calculate(equation : calculator.currentEquation!)
            calculator.equationView.updateCount()
            
            //update date
            calculator.currentEquation!.recentDate = Date()
        
            UIView.animate(withDuration : 0.3, animations :
            {
                calculator.searchView.alpha         = 1
                calculator.blurView.alpha           = 0.0
                calculator.equationList.alpha       = 0.0
                
                //update statusBar
                SM.updateStatusBar()
                    
            }, completion : { (finished) in
                calculator.blurView.removeFromSuperview()
                calculator.equationView.isUserInteractionEnabled    = true
                calculator.operationView.isUserInteractionEnabled   = true
                calculator.searchView.isUserInteractionEnabled      = true
                
            })
        
            calculator.equationField.becomeFirstResponder()
            
        case calculator.modelList :
            if calculator.selectedState == .Tag
            {
                calculator.selectFrom = .List
                
                if calculator.entityState == .EntityEquation
                {
                    SM.adjustSelection(withState : .Equation)
                    calculator.equationSections[indexPath.section][indexPath.row].select()
                    calculator.control.layout(cancel : .Equation)
                    calculator.selectionView.equation(selectFrom : calculator.selectFrom)
                }
                else
                {
                    SM.adjustSelection(withState : .Value)
                    calculator.valueSections[indexPath.section][indexPath.row].select()
                    calculator.control.layout(cancel : .Value)
                    calculator.selectionView.value(selectFrom : calculator.selectFrom)
                }
                
                //reload
                calculator.equationField.inputView = calculator.selectionView
                calculator.equationField.reloadInputViews()
                
                //display infoView
                calculator.infoView.show()
            }
        
        case calculator.recentList :
            switch calculator.recentState
            {
            case .RecentEquation :
                SM.adjustSelection(withState : .Equation)
                
                calculator.equationSections[indexPath.section][indexPath.row].select()
                calculator.equationSections[indexPath.section][indexPath.row].hit()
                
                calculator.control.layout(cancel : .Equation)
                
                calculator.selectFrom = .List
                calculator.selectionView.equation(selectFrom : calculator.selectFrom)
            
            case .RecentValue :
                SM.adjustSelection(withState : .Value)
                
                calculator.valueSections[indexPath.section][indexPath.row].select()
                calculator.valueSections[indexPath.section][indexPath.row].hit()
                
                calculator.control.layout(cancel : .Value)
                
                calculator.selectFrom = .List
                calculator.selectionView.value(selectFrom : calculator.selectFrom)
                
            default : return
            }
            
            calculator.equationField.inputView = calculator.selectionView
            calculator.equationField.reloadInputViews()
            
            //display infoView
            calculator.infoView.show()
            
            return
        
        case calculator.filterList :
            let filter = calculator.filters[indexPath.row]
            filter.selected = filter.selected.boolValue ? false : true
            calculator.filterList.reloadData()
        
        case calculator.manageList :
            if calculator.manageEditing
            {
                switch calculator.entityState
                {
                case .EntityEquation :
                    let equation = calculator.equationSections[indexPath.section][indexPath.row]
                    
                    if calculator.selectedEquations.contains(equation)
                    {
                        calculator.selectedEquations.remove(at : calculator.selectedEquations.index(of : equation)!)
                    }
                    else
                    {
                        calculator.selectedEquations.append(equation)
                    }
                    
                case .EntityValue :
                    let value = calculator.valueSections[indexPath.section][indexPath.row]
                    
                    if calculator.selectedValues.contains(value)
                    {
                        calculator.selectedValues.remove(at : calculator.selectedValues.index(of : value)!)
                    }
                    else
                    {
                        calculator.selectedValues.append(value)
                    }
                    
                case .EntityTag :
                    let tag = calculator.tagSections[indexPath.section][indexPath.row]
                    
                    if calculator.selectedTags.contains(tag)
                    {
                        calculator.selectedTags.remove(at : calculator.selectedTags.index(of : tag)!)
                    }
                    else
                    {
                        calculator.selectedTags.append(tag)
                    }
                    
                default : break
                }
                
                //reload selected
                calculator.manageList.reloadRows(at : [indexPath], with : .none)
                
                //update count
                calculator.manageVC!.updateSelectedCount()
            }
            else if calculator.operationState == .OnSearch
            {
                switch calculator.entityState
                {
                case .EntityEquation :
                    SM.adjustSelection(withState : .Equation)
                    
                    calculator.equationSections[indexPath.section][indexPath.row].select()
                    calculator.equationSections[indexPath.section][indexPath.row].hit()
                    
                    calculator.control.layout(cancel : .Equation)
                    
                    calculator.selectFrom = .List
                    calculator.selectionView.equation(selectFrom : calculator.selectFrom)
                    
                case .EntityValue :
                    SM.adjustSelection(withState : .Value)
                    
                    calculator.valueSections[indexPath.section][indexPath.row].select()
                    calculator.valueSections[indexPath.section][indexPath.row].hit()
                    
                    calculator.control.layout(cancel : .Value)
                    
                    calculator.selectFrom = .List
                    calculator.selectionView.value(selectFrom : calculator.selectFrom)
                    
                case .EntityTag :
                    SM.adjustSelection(withState : .Tag)
                    
                    calculator.selectedTag = calculator.tagSections[indexPath.section][indexPath.row]
                    calculator.tagSections[indexPath.section][indexPath.row].hit()
                    calculator.selectedState = .Tag
                    
                    calculator.control.layout(cancel : .Tag)
                    calculator.selectionView.listTag()
                    
                    //reload
                    calculator.tagList.reloadData()
                    
                default : break
                }
                
                calculator.valueField.resignFirstResponder()
                calculator.valueField.removeFromSuperview()
                
                calculator.equationField.inputView = calculator.selectionView
                calculator.equationField.reloadInputViews()
                calculator.equationField.becomeFirstResponder()
                
                //display infoView
                calculator.blurView.isHidden = true
                calculator.infoView.show()

                return
            }
            else
            {
                switch calculator.entityState
                {
                case .EntityGroup :
                    let group = calculator.groupSections[indexPath.section][indexPath.row]
                    
                    calculator.entityState          = .EntityValue
                    calculator.manageSelectedGroup  = group
                    
                    calculator.manageVC!.updateTopBar()
                    calculator.entitySegment.activateLayout()
                    collection.configureManageSections()
                    
                    return
                    
                case .EntityEquation :
                    SM.adjustSelection(withState : .Equation)
                    
                    calculator.equationSections[indexPath.section][indexPath.row].select()
                    calculator.equationSections[indexPath.section][indexPath.row].hit()
                    
                    calculator.control.layout(cancel : .Equation)
                    
                    calculator.selectFrom = .List
                    calculator.selectionView.equation(selectFrom : calculator.selectFrom)
                    
                case .EntityValue :
                    SM.adjustSelection(withState : .Value)
                    
                    calculator.valueSections[indexPath.section][indexPath.row].select()
                    calculator.valueSections[indexPath.section][indexPath.row].hit()
                    
                    calculator.control.layout(cancel : .Value)
                    
                    calculator.selectFrom = .List
                    calculator.selectionView.value(selectFrom : calculator.selectFrom)
                
                case .EntityTag :
                    SM.adjustSelection(withState : .Tag)
                    
                    calculator.selectedTag = calculator.tagSections[indexPath.section][indexPath.row]
                    calculator.tagSections[indexPath.section][indexPath.row].hit()
                    calculator.selectedState = .Tag
                    
                    calculator.control.layout(cancel : .Tag)
                    calculator.selectionView.listTag() //tweak for manage list
                
                default : break
                }
                
                //reload
                calculator.equationField.inputView = calculator.selectionView
                calculator.equationField.reloadInputViews()
                calculator.equationField.becomeFirstResponder()
                
                //display infoView
                calculator.infoView.show()
            }
        
        case calculator.groupList :
            //set group for new entity (input)
            if calculator.valueField.isFirstResponder
            {
                //fetch group
                let group = calculator.groupSections[indexPath.section][indexPath.row]
                
                //update path
                calculator.entityGroup = calculator.entityGroup != nil && calculator.entityGroup == group ? nil : group
                
                //activate editView
                calculator.editView.show()
                
                //reload
                calculator.groupList.reloadData()
            }
            //set group for existing entity
            else if calculator.operationState == .GroupSelect
            {
                //fetch group
                let group = calculator.groupSections[indexPath.section][indexPath.row]
                
                //case
                switch calculator.selectedState
                {
                case .Equation, .SearchedEquation :
                    let targetEquation = calculator.selectedState == .Equation ?
                                         calculator.selectedEquation : calculator.selectedSearchedEquation
                    
                    targetEquation?.group = targetEquation?.group != nil && targetEquation?.group == group ? nil : group
                    calculator.equationView.activateEquation()
                
                case .Value, .SearchedValue :
                    let targetValue = calculator.selectedState == .Value ?
                                      calculator.selectedValue : calculator.selectedSearchedValue
                    
                    targetValue?.group = targetValue?.group != nil && targetValue?.group == group ? nil : group
                
                default : break
                }
                
                //update entityGroup
                calculator.entityGroup = calculator.entityGroup != nil && calculator.entityGroup == group ?
                                         nil : group
                
                //reload
                calculator.groupList.reloadData()
                calculator.metaList.reloadData()
            }
            //select group for manageList
            else if calculator.manageEditing
            {
                //set none
                if indexPath.section == 0
                {
                    switch calculator.entityState
                    {
                    case .EntityEquation :
                        for equation in calculator.selectedEquations
                        {
                            equation.group = nil
                        }
                        
                    case .EntityValue :
                        for value in calculator.selectedValues
                        {
                            value.group = nil
                        }
                        
                    default : return
                    }
                }
                //set group
                else
                {
                    //fetch group
                    let group = calculator.groupSections[indexPath.section - 1][indexPath.row]
                    
                    switch calculator.entityState
                    {
                    case .EntityEquation :
                        for equation in calculator.selectedEquations
                        {
                            equation.group = group
                        }
                        
                    case .EntityValue :
                        for value in calculator.selectedValues
                        {
                            value.group = group
                        }
                        
                    default : return
                    }
                }
                
                //update buttons for selected group
                if calculator.manageSelectedGroup != nil
                {
                    var selectedCount = 0
                    
                    if calculator.entityState == .EntityEquation
                    {
                        for equation in calculator.selectedEquations
                        {
                            if calculator.manageSelectedGroup!.fetchEquations().contains(equation)
                            {
                                selectedCount += 1
                            }
                            else
                            {
                                calculator.selectedEquations.remove(at : calculator.selectedEquations.index(of : equation)!)
                            }
                        }
                    }
                    else
                    {
                        for value in calculator.selectedValues
                        {
                            if calculator.manageSelectedGroup!.fetchValues().contains(value)
                            {
                                selectedCount += 1
                            }
                            else
                            {
                                calculator.selectedValues.remove(at : calculator.selectedValues.index(of : value)!)
                            }
                        }
                    }
                    
                    //update buttons
                    calculator.manageVC!.deleteLbl.text = selectedCount != 0 ? "#delete".local :
                                                                               "\("#delete".local) (\(selectedCount)) "
                    calculator.manageVC!.groupLbl.text  = selectedCount != 0 ? "#group".local :
                                                                               "\("#group".local) (\(selectedCount)) "
                    calculator.manageVC!.copyLbl.text   = selectedCount != 0 ? "#duplicate".local :
                                                                               "\("#duplicate".local) (\(selectedCount)) "
                }
                
                //reload
                collection.configureManageSections()
                calculator.entitySegment.activateLayout()
                
                //animate
                UIView.animate(withDuration : 0.25, animations : {
                    calculator.groupList.alpha              = 0
                    
                }) { (finished) in
                    calculator.manageVC!.topBar.isHidden    = false
                    calculator.entitySegment.isHidden       = false
                    calculator.manageList.isHidden          = false
                    
                    calculator.groupList.isHidden           = true
                    calculator.groupList.removeFromSuperview()
                    
                    UIView.animate(withDuration : 0.25, animations : {
                        calculator.manageVC!.topBar.alpha   = 1
                        calculator.entitySegment.alpha      = 1
                        calculator.manageList.alpha         = 1
                        calculator.groupList.alpha          = 1
                        
                    })
                }
                
            }
            //select group
            else
            {
                //set selected
                calculator.selectedGroup = calculator.groupSections[indexPath.section][indexPath.row]
                
                //configure sections
                self.configureGroupEntitySections()
                
                //reload
                calculator.groupList.reloadData()
                calculator.groupEntityList.reloadData()
                
                //update addToGroup icon
                let targetBtn = calculator.extensionButtons[4]
                switch calculator.highlightedState
                {
                case .Equation :
                    targetBtn.iconLbl?.text = calculator.highlightedEquation?.group != nil &&
                    calculator.highlightedEquation?.group == calculator.selectedGroup ?
                    Icon.GroupOut.rawValue : Icon.GroupIn.rawValue
                    targetBtn.activate()
                
                case .Value :
                    targetBtn.iconLbl?.text = calculator.highlightedValue?.group != nil &&
                    calculator.highlightedValue?.group == calculator.selectedGroup ?
                    Icon.GroupOut.rawValue : Icon.GroupIn.rawValue
                    targetBtn.activate()
                
                case .Operation :
                    targetBtn.iconLbl?.text = Icon.GroupIn.rawValue
                    targetBtn.deactivate()
                }
            }
        
        case calculator.groupEntityList :
            switch calculator.groupState
            {
            case .GroupEquation :
                SM.adjustSelection(withState : .Equation)
                
                calculator.equationSections[indexPath.section][indexPath.row].select()
                calculator.equationSections[indexPath.section][indexPath.row].hit()
                
                calculator.control.layout(cancel : .Equation)
                
                calculator.selectFrom = .List
                calculator.selectionView.equation(selectFrom : calculator.selectFrom)
            
            case .GroupValue :
                SM.adjustSelection(withState : .Value)
                
                calculator.valueSections[indexPath.section][indexPath.row].select()
                calculator.valueSections[indexPath.section][indexPath.row].hit()

                calculator.control.layout(cancel : .Value)
                
                calculator.selectFrom = .List
                calculator.selectionView.value(selectFrom : calculator.selectFrom)
            
            case .GroupTag :
                SM.adjustSelection(withState : .Tag)
                
                calculator.selectedTag = calculator.tagSections[indexPath.section][indexPath.row]
                calculator.tagSections[indexPath.section][indexPath.row].hit()
                calculator.selectedState = .Tag
                
                calculator.control.layout(cancel : .Tag)
                calculator.selectionView.listTag()
            
            default : return
            }
            
            calculator.equationField.inputView = calculator.selectionView
            calculator.equationField.reloadInputViews()
            
            //display infoView
            calculator.infoView.show()
        
        case calculator.tagList :
            //fetch tag
            let tag = calculator.tagSections[indexPath.section][indexPath.row]
            
            //set tag for new entity (input)
            if calculator.valueField.isFirstResponder
            {
                //case
                if calculator.entityTags.contains(tag)
                {
                    calculator.entityTags.remove(at : calculator.entityTags.index(of : tag)!)
                }
                else
                {
                    calculator.entityTags.append(tag)
                }
            }
            //set tag for existing entity
            else if calculator.operationState == .TagSelect
            {
                //case
                switch calculator.selectedState
                {
                case .Equation, .SearchedEquation :
                    let targetEquation = calculator.selectedState == .Equation ?
                                         calculator.selectedEquation : calculator.selectedSearchedEquation
                    
                    targetEquation!.fetchTags().contains(tag) ?
                    targetEquation!.remove(tag : tag) : targetEquation!.append(tag : tag)
                    
                case .Value, .SearchedValue :
                    let targetValue = calculator.selectedState == .Value ?
                                      calculator.selectedValue : calculator.selectedSearchedValue
                    
                    targetValue!.fetchTags().contains(tag) ?
                    targetValue!.remove(tag : tag) : targetValue!.append(tag : tag)
                    
                default : return
                }
            }
            //recent tagList
            else
            {
                //adjust selectionView
                SM.adjustSelection(withState : .Tag)
                
                //select
                calculator.selectedTag = tag
                tag.hit()
                calculator.selectedState = .Tag
                
                calculator.control.layout(cancel : .Tag)
                calculator.selectionView.listTag()
                
                calculator.equationField.inputView = calculator.selectionView
                calculator.equationField.reloadInputViews()
                
                //display infoView
                calculator.infoView.show()
                
                return
            }
        
            //reload
            calculator.tagList.reloadData()
            calculator.metaList.reloadData()

        case calculator.unitGroupList :
            let unitGroup = calculator.unitGroups[indexPath.row]
            
            //update selected
            calculator.selectedUnitGroup = unitGroup
            
            //validate
            if unitGroup.name == "#currency".local
            {
                calculator.checkNetworkStatus()
            }
            else
            {
                calculator.convertView.refreshLbl.isHidden = false
                calculator.unitList.isHidden = false
                calculator.convertView.statusLbl.isHidden = true
            }
            
            //fetch selected units
            calculator.selectedUnits = calculator.selectedUnitGroup!.fetchUnits().filter({ $0.selected.boolValue == true })
            
            //reload
            calculator.unitGroupList.reloadData()
            calculator.unitList.reloadData()
        
        case calculator.unitList :
            if calculator.valueField.isFirstResponder
            {
                let unit = calculator.selectedUnits[indexPath.row]
                calculator.entityUnit = calculator.entityUnit != nil ? calculator.entityUnit != unit ? unit : nil : unit
                
                //activate editView
                calculator.editView.show()
                
                //reload
                calculator.unitList.reloadData()
            }
            else
            {
                if calculator.operationState == .UnitSelect
                {
                    let unit = calculator.selectedUnits[indexPath.row]
                    
                    switch calculator.selectedState
                    {
                    case .Equation, .SearchedEquation :
                        let targetEquation = calculator.selectedState == .Equation ?
                                             calculator.selectedEquation : calculator.selectedSearchedEquation
                        
                        targetEquation?.unit = targetEquation?.unit != nil && targetEquation?.unit == unit ? nil : unit
                        
                        //update holdingValue
                        if let holdingValue = DM.fetchValue(withEquationUID : targetEquation!.uid)
                        {
                            holdingValue.unit = targetEquation!.unit
                        }
                        
                        if calculator.currentEquation == targetEquation
                        {
                            calculator.equationView.activateEquation()
                        }
                        calculator.unitList.reloadData()
                    
                        if calculator.searchedEquations.contains(targetEquation!)
                        {
                            calculator.searchView.reloadData()
                        }
                    
                    case .Value, .SearchedValue :
                        let targetValue = calculator.selectedState == .Value ?
                                          calculator.selectedValue : calculator.selectedSearchedValue
                        
                        targetValue?.unit = targetValue?.unit != nil && targetValue?.unit == unit ? nil : unit
                        
                        //update subEquation
                        if let subEquation = DM.fetchEquation(forUID : targetValue!.uid)
                        {
                            subEquation.unit = targetValue!.unit
                        }
                        
                        if calculator.currentEquation!.fetchValues().contains(targetValue!)
                        {
                            calculator.operationView.reloadData()
                        }
                        calculator.unitList.reloadData()
                    
                        if calculator.searchedValues.contains(targetValue!)
                        {
                            calculator.searchView.reloadData()
                        }
                    
                    default : break
                    }
                    
                    //reload
                    calculator.modelList.reloadData()
                    calculator.metaList.reloadData()
                }
                else
                {
                    //fetch model
                    let unit = calculator.selectedUnits[indexPath.row]
                    
                    //validate
                    if let targetEquation = calculator.highlightedEquation
                    {
                        //set model
                        targetEquation.unit = targetEquation.unit == unit ? nil : unit
                        
                        //update
                        calculator.equationView.activateEquation()
                    }
                    else if let targetValue = calculator.highlightedValue
                    {
                        //set model
                        targetValue.unit = targetValue.unit == unit ? nil : unit
                        
                        //update
                        calculator.operationView.reloadData()
                    }
                    
                    calculator.calculate(equation : calculator.currentEquation!)
                    
                    //reload
                    calculator.unitList.reloadData()
                }
            }
        
        case calculator.unitPickerList :
            var unit : Unit?
            if calculator.selectedUnitGroup!.name == "#currency".local
            {
                unit = calculator.currencySections[indexPath.section][indexPath.row]
            }
            else
            {
                unit = calculator.selectedUnitGroup!.fetchUnits()[indexPath.row]
            }
            unit!.selected = unit!.selected.boolValue ? false : true
            calculator.unitPickerList.reloadRows(at : [indexPath], with : .none)
        
        case calculator.settingList :
            let settingTitle                = self.settingTitles[indexPath.section][indexPath.row]
            let settingDepthVC              = SettingDepthVC()
            settingDepthVC.titleLbl.text    = settingTitle
            
            switch settingTitle
            {
            case "#setting".local   : calculator.settingState = .Settings
            case "S1.suggest".local : calculator.settingVC!.loadRecommendActivity(); return
            case "S1.review".local  :
                //prepare URL
                let url = URL(string : "https://itunes.apple.com/app/id1283009765?action=write-review&mt=8")
                
                //validate
                if UIApplication.shared.canOpenURL(url!)
                {
                    UIApplication.shared.open(url!, options : [:], completionHandler : nil)
                }
                else
                {
                    //alert
                    let message = "#appStoreOpenFailed".local
                    let alert = UIAlertController(title : nil, message : message, preferredStyle : .alert)
                    alert.addAction(UIAlertAction(title : "#OK".local, style : .destructive) { action in
                        calculator.settingList.reloadData()
                    })
                    
                    //show alert
                    calculator.settingVC!.present(alert, animated : true, completion : nil)
                }
                
                calculator.settingList.deselectRow(at : indexPath, animated : false)
                return
                
            case "S1.support".local : calculator.settingState = .Support
            case "S1.version".local : calculator.settingState = .Version
            case "S1.legal".local   : calculator.settingState = .Legal
            case "S1.reset".local   : calculator.blurView.activateDataReset(); return
            default : return
                
            }
        
            //push to settingDepthVC
            calculator.viewState = .SettingDepth
            calculator.settingVC!.navigationController?.pushViewController(settingDepthVC, animated : true)
        
        case calculator.settingDepthList :
            switch calculator.settingState
            {
            case .Settings :
                let settingInDepthVC = SettingInDepthVC()
                settingInDepthVC.titleLbl.text = self.settingDepthItems[indexPath.section][indexPath.row]
                
                switch (indexPath.section, indexPath.row)
                {
                case (1, 0) : calculator.settingState = .SelectTheme
                case (1, 1) : calculator.settingState = .ChangeFont
                default     : return
                }
            
                //push to settingInDepthVC
                calculator.viewState = .SettingInDepth
                calculator.settingVC!.navigationController?.pushViewController(settingInDepthVC, animated : true)

            case .Support :
                if MFMailComposeViewController.canSendMail()
                {
                    let settingDepthVC = calculator.settingVC!.navigationController?.viewControllers.last! as! SettingDepthVC
                    let mailComposeVC = MFMailComposeViewController()
                    mailComposeVC.mailComposeDelegate = settingDepthVC
                    mailComposeVC.setToRecipients(["support@zero-calculator.com"])
                    
                    //case-scenario
                    switch (indexPath.section, indexPath.row)
                    {
                    case (0, 0) :
                        mailComposeVC.setSubject("S2-2.inquireTitle".local)
                        mailComposeVC.setMessageBody("<p>\("S2-2.inquireBody".local)</p>", isHTML : true)
                    
                        //present mailComposeVC
                        calculator.settingVC!.navigationController?.present(mailComposeVC, animated : true, completion : nil)
                    
                    case (1, 0) :
                        mailComposeVC.setSubject("S2-2.suggestTitle".local)
                        mailComposeVC.setMessageBody("<p>\("S2-2.suggestBody".local)</p>", isHTML : true)
                    
                        //present mailComposeVC
                        calculator.settingVC!.navigationController?.present(mailComposeVC, animated : true, completion : nil)
                    
                    case (2, 0) :
                        calculator.blurView.activateTrouble()
                    
                    case (3, 0) :
                        mailComposeVC.setSubject("S2-2.translateTitle".local)
                        mailComposeVC.setMessageBody("<p>\("S2-2.translateBody".local)</p>", isHTML : true)
                    
                        //present mailComposeVC
                        calculator.settingVC!.navigationController?.present(mailComposeVC, animated : true, completion : nil)
                    
                    default : return
                    }
                }
                else
                {
                    //show failure alert
                    let alert = UIAlertController(title : "#noMailAccount".local,
                                                  message : "#noAccountCaption".local, preferredStyle : .alert)
                    alert.addAction(UIAlertAction(title : "#OK".local, style : .destructive, handler : nil))
                    calculator.settingVC!.present(alert, animated : true, completion : nil)
                }
            
            case .Legal :
                let settingInDepthVC = SettingInDepthVC()
                settingInDepthVC.titleLbl.text = self.legalDepthItems[indexPath.row]
                
                switch (indexPath.section, indexPath.row)
                {
                case (0, 0) : calculator.settingState = .Attributions
                case (0, 1) : calculator.settingState = .PrivacyPolicy
                case (0, 2) : calculator.settingState = .Disclaimer
                default     : return
                }
            
                //push to settingInDepthVC
                calculator.viewState = .SettingInDepth
                calculator.settingVC!.navigationController?.pushViewController(settingInDepthVC, animated : true)
            
            default : return
            }
        
        case calculator.settingInDepthList :
            //changeFont
            if calculator.settingState == .ChangeFont
            {
                let font = calculator.fonts[indexPath.row]
                
                if font.selected == true
                {
                    return
                }
                else
                {
                    //set selected
                    font.selected           = true
                    calculator.selectedFont = font
                    
                    //de-select others
                    for _font in calculator.fonts
                    {
                        if _font != font
                        {
                            _font.selected = false
                        }
                    }
                }
                
                //update
                DM.saveContext()
                
                //update layout
                let settingInDepthVC                            = rootVC.navigationController?.viewControllers.last
                                                                  as! SettingInDepthVC
                
                settingInDepthVC.titleLbl.font                  = SM.defaultFont(withHeight : barItemHeight * 0.5)
                settingInDepthVC.backBtn.titleLabel?.font       = SM.defaultFont(withHeight : barItemHeight * 0.5) //0.3
                
                settingInDepthVC.mediumLbl.font                 = SM.defaultFont(withHeight : topBarHeight * 0.2)
                settingInDepthVC.bigLbl.font                    = SM.defaultFont(withHeight : topBarHeight * 0.2)
                
                //update labels
                calculator.wrongEquation != nil ?
                calculator.equationView.activateError(withDescription : "#calculationErrorCaption".local) :
                calculator.equationView.activateEquation()
                calculator.equationView.groupLbl.font           = SM.defaultFont(withHeight : cellHeight * 0.25)
                calculator.equationView.countLbl.font           = SM.defaultFont(withHeight : cellHeight * 0.25)
                
                calculator.recentView.refreshLbl.font           = SM.defaultFont(withHeight : cellHeight * 0.4)
                calculator.convertView.refreshLbl.font          = SM.defaultFont(withHeight : cellHeight * 0.4)
                calculator.convertView.statusLbl.font           = SM.defaultFont(withHeight : cellHeight * 0.4)
                
                calculator.recentView.refreshLbl.frame.size     = CGSize(width : refWidth,  height : cellHeight)
                calculator.convertView.refreshLbl.frame.size    = CGSize(width : (refWidth * 0.8) - 1,  height : cellHeight)
                calculator.recentView.refreshLbl.frame.size     = CGSize(width : (refWidth * 0.8) - 1,  height : cellHeight)
                
                calculator.recentView.refreshLbl.center         = CGPoint(x : refWidth / 2,
                                                                          y : calculator.recentView.refreshLbl.center.y)
                
                //update list
                switch calculator.controlState
                {
                case .Recent :
                    calculator.recentList.reloadData()
                    
                case .Group :
                    calculator.groupView.updateLayout(withAnimation : false)
                    calculator.groupList.reloadData()
                    calculator.groupEntityList.reloadData()
                    
                case .Convert :
                    calculator.unitGroupList.reloadData()
                    calculator.unitList.reloadData()
                    
                    //set scroll
                    calculator.unitGroupList.isScrollEnabled    = isBigFont ? true : false
                    
                default : break
                }
                
                calculator.settingInDepthList.reloadData()
            }
        
        case calculator.selectionList :
            
            //case-scenario
            switch calculator.selectionListState
            {
            case .AttachPhoto :
                if indexPath.section == 0
                {
                    let settingDepthVC = calculator.settingVC!.navigationController?.viewControllers.last! as! SettingDepthVC
                    
                    //attach
                    if indexPath.row == 0
                    {
                        UIView.animate(withDuration : 0.3, animations :
                        {
                            calculator.blurView.alpha = 0
                            calculator.selectionList.alpha = 0
                                
                        }, completion : { (finished) in

                            calculator.blurView.removeFromSuperview()
                            
                            //display imagePicker
                            let imagePC = UIImagePickerController()
                            imagePC.delegate = settingDepthVC
                            imagePC.allowsEditing = true
                            imagePC.sourceType = .photoLibrary
                            
                            calculator.settingVC!.navigationController?.present(imagePC, animated : true, completion : nil)
                            
                            //update statusBar
                            SM.updateStatusBar()
                        })
                    }
                    //skip
                    else
                    {
                        UIView.animate(withDuration : 0.3, animations :
                        {
                            calculator.blurView.alpha = 0
                            calculator.selectionList.alpha = 0
                                
                        }, completion : { (finished) in

                            calculator.blurView.removeFromSuperview()
                            
                            let mailComposeVC = MFMailComposeViewController()
                            mailComposeVC.mailComposeDelegate = settingDepthVC
                            mailComposeVC.setToRecipients(["support@zero-calculator.com"])
                            mailComposeVC.setSubject("S2-2.troubleTitle".local)
                            mailComposeVC.setMessageBody("<p>\("S2-2.troubleBody".local)</p>", isHTML : true)
                            
                            //display mailComposer
                            calculator.settingVC!.navigationController?.present(mailComposeVC, animated : true, completion : nil)
                        })
                    }
                }
                //cancel
                else
                {
                    UIView.animate(withDuration : 0.3, animations :
                    {
                        calculator.blurView.alpha = 0
                        calculator.selectionList.alpha = 0
                            
                    }, completion : { (finished) in

                        calculator.blurView.removeFromSuperview()
                        calculator.settingDepthList.isUserInteractionEnabled = true
                    })
                }
            
            case .ResetData :
                //reset
                if indexPath.section == 0
                {
                    //update state
                    calculator.selectionListState = .ResetDataConfirm
                    
                    //prepare selectionList
                    let selectionHeight : CGFloat = 110 + (cellHeight * 2)
                    let selectionPos    = CGPoint(x : 0, y : refHeight - selectionHeight)
                    let selectionSize   = CGSize(width : refWidth, height : selectionHeight)
                    calculator.selectionList.frame = CGRect(origin : selectionPos, size : selectionSize)
                    
                    //prepare selection model
                    calculator.selectionTitles.removeAll()
                    calculator.selectionTitles.append("S1.reset.finalConfirm".local)
                    
                    calculator.selectionList.alpha = 1.0
                    calculator.selectionList.reloadData()
                }
                //cancel
                else
                {
                    UIView.animate(withDuration : 0.3, animations :
                    {
                        calculator.blurView.alpha = 0
                        calculator.selectionList.alpha = 0
                            
                    }, completion : { (finished) in
                        
                        calculator.blurView.removeFromSuperview()
                        calculator.settingList.isUserInteractionEnabled = true
                    })
                }
            
            case .ResetDataConfirm :
                //initiate reset procedure
                if indexPath.section == 0
                {
                    //deregister units
                    for unitGroup in calculator.unitGroups
                    {
                        for unit in unitGroup.fetchUnits()
                        {
                            unit.selected = false
                        }
                    }
                    
                    //deregister filters
                    for filter in calculator.filters
                    {
                        filter.selected = false
                    }
                    
                    //delete groups
                    for group in calculator.groups
                    {
                        DM.managedObjectContext.delete(group)
                    }
                    
                    //delete current equation
                    for value in calculator.currentEquation!.fetchValues()
                    {
                        DM.managedObjectContext.delete(value)
                    }
                    for operation in calculator.currentEquation!.fetchOperations()
                    {
                        DM.managedObjectContext.delete(operation)
                    }
                    DM.managedObjectContext.delete(calculator.currentEquation!)
                    
                    //delete equations
                    for equation in calculator.equations
                    {
                        for value in equation.fetchValues()
                        {
                            DM.managedObjectContext.delete(value)
                        }
                        for operation in equation.fetchOperations()
                        {
                            DM.managedObjectContext.delete(operation)
                        }
                        DM.managedObjectContext.delete(equation)
                    }
                    
                    //delete values
                    for value in calculator.values
                    {
                        DM.managedObjectContext.delete(value)
                    }
                    
                    //delete tags
                    for tag in calculator.tags
                    {
                        DM.managedObjectContext.delete(tag)
                    }
                    
                    //flush arrays
                    calculator.groups               .removeAll()
                    calculator.equations            .removeAll()
                    calculator.values               .removeAll()
                    calculator.tags                 .removeAll()
                    
                    calculator.currentEquations     .removeAll()
                    calculator.searchedEquations    .removeAll()
                    calculator.searchedValues       .removeAll()
                    calculator.selectedEquations    .removeAll()
                    calculator.selectedValues       .removeAll()
                    calculator.selectedUnits        .removeAll()
                    calculator.entityTags           .removeAll()
                    
                    calculator.groupSections        .removeAll()
                    calculator.equationSections     .removeAll()
                    calculator.valueSections        .removeAll()
                    calculator.tagSections          .removeAll()
                    calculator.recentEquations      .removeAll()
                    calculator.recentValues         .removeAll()
                    
                    calculator.sectionIndexTitles   .removeAll()
                    calculator.entityIndexTitles    .removeAll()
                    
                    //nullify pointers
                    calculator.entityGroup              = nil
                    calculator.entityUnit               = nil
                    calculator.manageSelectedGroup      = nil
                    calculator.selectedGroup            = nil
                    calculator.highlightedEquation      = nil
                    calculator.wrongEquation            = nil
                    calculator.valueBeforeEquation      = nil
                    calculator.operationBeforeEquation  = nil
                    
                    //set new equation
                    calculator.currentEquation          = DM.fetchInventoryEquation()
                    calculator.currentEquations.append(calculator.currentEquation!)
                    
                    if !calculator.equations.contains(calculator.currentEquation!)
                    {
                        calculator.equations.append(calculator.currentEquation!)
                    }
                    if !calculator.values.contains(calculator.currentEquation!.firstValue()!)
                    {
                        calculator.values.append(calculator.currentEquation!.firstValue()!)
                    }
                    if !calculator.recentValues.contains(calculator.currentEquation!.firstValue()!)
                    {
                        calculator.recentValues.append(calculator.currentEquation!.firstValue()!)
                    }
                    
                    //highlight
                    calculator.currentEquation!.lastValue()?.highlight()
                    
                    //update state
                    calculator.operationState = .ValueTyping
                    
                    //reset search
                    calculator.resetSearch()
                    
                    //update calculate
                    calculator.equationView.updateCount()
                    calculator.calculate(equation : calculator.currentEquation!)
                    
                    //refresh control
                    calculator.refreshControl()
                    
                    UIView.animate(withDuration : 0.3, animations :
                    {
                        calculator.blurView.alpha = 0.0
                        calculator.selectionList.alpha = 0.0
                            
                    }, completion : { (finished) in

                        calculator.blurView.removeFromSuperview()
                        calculator.settingList.isUserInteractionEnabled = true
                    })
                    
                    //save DB
                    DM.saveContext()
                    
                    //notify with alarm
                    let message = "#dataResetComplete".local
                    let alert = UIAlertController(title : nil, message : message, preferredStyle : .alert)
                    alert.addAction(UIAlertAction(title : "#OK".local, style : .destructive, handler : nil))

                    //present alert
                    if calculator.settingVC!.presentedViewController == nil
                    {
                        calculator.settingVC!.present(alert, animated : true, completion : nil)
                    }
                    else
                    {
                        calculator.settingVC!.dismiss(animated : false, completion :
                        {
                            calculator.settingVC!.present(alert, animated : true, completion : nil)
                        })
                    }
                }
                //cancel (abort reset)
                else
                {
                    UIView.animate(withDuration : 0.3, animations :
                    {
                        calculator.blurView.alpha = 0.0
                        calculator.selectionList.alpha = 0.0
                            
                    }, completion : { (finished) in

                        calculator.blurView.removeFromSuperview()
                        calculator.settingList.isUserInteractionEnabled = true
                    })
                }
            
            case .EquationList :
                UIView.animate(withDuration : 0.3, animations :
                {
                    calculator.searchView.alpha         = 1
                    calculator.blurView.alpha           = 0.0
                    calculator.equationList.alpha       = 0.0
                    calculator.selectionList.alpha      = 0.0
                    
                    //update statusBar
                    SM.updateStatusBar()
                        
                }, completion : { (finished) in
                    
                    calculator.blurView.removeFromSuperview()
                    calculator.equationView.isUserInteractionEnabled    = true
                    calculator.operationView.isUserInteractionEnabled   = true
                    calculator.searchView.isUserInteractionEnabled      = true
                })
                
                calculator.equationField.becomeFirstResponder()
            }
            
            //de-select selected indexPath
            if let selectedIndexPath = calculator.settingList.indexPathForSelectedRow
            {
                calculator.settingList.deselectRow(at : selectedIndexPath, animated : false)
            }
            if let selectedIndexPath = calculator.settingDepthList.indexPathForSelectedRow
            {
                calculator.settingDepthList.deselectRow(at : selectedIndexPath, animated : false)
            }
            if let selectedIndexPath = calculator.selectionList.indexPathForSelectedRow
            {
                calculator.selectionList.deselectRow(at : selectedIndexPath, animated : false)
            }
        
        default : return
        }
        
        DM.saveContext()
    }
    
    func tableView(_ tableView : UITableView, canEditRowAt indexPath : IndexPath) -> Bool
    {
        switch tableView
        {
        case calculator.equationList    : return true
        case calculator.recentList      : return true
        case calculator.groupList       : return calculator.valueField.isFirstResponder ? false : true
        case calculator.groupEntityList : return true
        case calculator.tagList         : return calculator.operationState != .TagSelect && calculator.viewState == .Root ?
                                          true : false
        case calculator.manageList      : return calculator.manageEditing || calculator.operationState == .OnSearch ?
                                          false : true
        case calculator.unitList        : return true
        case calculator.modelList       :
            switch calculator.selectedState
            {
            case .Equation, .SearchedEquation, .Value, .SearchedValue   : return false
            default                                                     : return true
            }

        default                         : return false
        }
    }
    
    func tableView(_ tableView : UITableView, willBeginEditingRowAt indexPath : IndexPath)
    {
        switch tableView
        {
        case calculator.recentList      : calculator.recentView.refreshLbl.isHidden = true
        case calculator.groupList       : calculator.groupView.groupRefreshLbl.isHidden = true
        case calculator.groupEntityList : calculator.groupView.refreshLbl.isHidden = true
        case calculator.unitList        : calculator.convertView.refreshLbl.isHidden = true
        default                         : return
        }
    }
    
    func tableView(_ tableView : UITableView, didEndEditingRowAt indexPath : IndexPath?)
    {
        switch tableView
        {
        case calculator.recentList      : calculator.recentView.refreshLbl.isHidden = false
        case calculator.groupList       : calculator.groupView.groupRefreshLbl.isHidden = false
        case calculator.groupEntityList : calculator.groupView.refreshLbl.isHidden = false
        case calculator.unitList        : calculator.convertView.refreshLbl.isHidden = false
        default                         : return
        }
    }
    
    func tableView(_ tableView : UITableView, editingStyleForRowAt indexPath : IndexPath) -> UITableViewCellEditingStyle
    {
        switch tableView
        {
        case calculator.equationList    : return .none
        case calculator.recentList      : return .delete
        case calculator.groupList       : return calculator.valueField.isFirstResponder ? .none : .delete
        case calculator.groupEntityList : return .delete
        case calculator.manageList      : return calculator.manageList.isEditing ? .none : .delete
        default                         : return .delete
        }
    }
    
    func tableView(_ tableView : UITableView, shouldIndentWhileEditingRowAt indexPath : IndexPath) -> Bool
    {
        return false
    }
    
    func tableView(_ tableView : UITableView, editActionsForRowAt indexPath : IndexPath) -> [UITableViewRowAction]?
    {
        switch tableView
        {
        case calculator.groupList :
            if !calculator.valueField.isFirstResponder
            {
                //set selected group
                calculator.groupSections[indexPath.section][indexPath.row].select()
                
                //create actions
                let editAction = UITableViewRowAction(style : .normal, title : "#edit".local) { (action, _indexPath) in
                    SM.adjustSelection(withState : .GroupEdit)
                    
                    calculator.control.layout(cancel : .GroupEdit)
                    
                    calculator.selectionView.groupEdit()
                    calculator.equationField.inputView = calculator.selectionView
                    calculator.equationField.reloadInputViews()
                    
                }
                
                //action attributes
                editAction.backgroundColor = .black
                
                return [editAction]
            }
        
        case calculator.manageList :
            if calculator.manageEditing
            {
                return nil
            }
            
            switch calculator.entityState
            {
            case .EntityGroup :
                //select target group
                calculator.groupSections[indexPath.section][indexPath.row].select()
                
                //buttons
                let editBtn = UITableViewRowAction(style : .normal, title : "#edit".local) { (action, _indexPath) in
                    SM.adjustSelection(withState : .GroupEdit)
                    
                    calculator.control.layout(cancel : .GroupEdit)
                    
                    calculator.selectionView.groupEdit()
                    calculator.equationField.inputView = calculator.selectionView
                    calculator.equationField.reloadInputViews()
                    
                    calculator.equationField.becomeFirstResponder()
                }
                let deleteBtn = UITableViewRowAction(style : .destructive, title : "#delete".local) { (action, _indexPath) in
                    SM.adjustSelection(withState : .Delete)
                    
                    calculator.control.layout(cancel : .Delete)
                    
                    calculator.selectionView.delete(state : .EntityGroup)
                    calculator.equationField.inputView = calculator.selectionView
                    calculator.equationField.reloadInputViews()
                    
                    calculator.equationField.becomeFirstResponder()
                }
                
                //attributes
                editBtn.backgroundColor = .black
                deleteBtn.backgroundColor = .red
                
                return [editBtn, deleteBtn]
        
            case .EntityEquation :
                //select target equation
                calculator.equationSections[indexPath.section][indexPath.row].select()
                
                //button
                let deleteBtn = UITableViewRowAction(style : .destructive, title : "#delete".local) { (action, _indexPath) in
                    SM.adjustSelection(withState : .Delete)
                    
                    calculator.control.layout(cancel : .Delete)
                    
                    calculator.selectionView.delete(state : .EntityEquation)
                    calculator.equationField.inputView = calculator.selectionView
                    calculator.equationField.reloadInputViews()
                    
                    calculator.equationField.becomeFirstResponder()
                    
                }
                
                //attribute
                deleteBtn.backgroundColor = .red
                
                return [deleteBtn]
            
            case .EntityValue :
                //select target value
                calculator.valueSections[indexPath.section][indexPath.row].select()
                
                //button
                let deleteBtn = UITableViewRowAction(style : .destructive, title : "#delete".local) { (action, _indexPath) in
                    SM.adjustSelection(withState : .Delete)
                    
                    calculator.control.layout(cancel : .Delete)
                    
                    calculator.selectionView.delete(state : .EntityValue)
                    calculator.equationField.inputView = calculator.selectionView
                    calculator.equationField.reloadInputViews()

                    calculator.equationField.becomeFirstResponder()
                }
                
                //attributes
                deleteBtn.backgroundColor = .red
                
                return [deleteBtn]
            
            case .EntityTag :
                //select target tag
                calculator.tagSections[indexPath.section][indexPath.row].select()
                
                //button
                let deleteBtn = UITableViewRowAction(style : .destructive, title : "#delete".local) { (action, _indexPath) in
                    SM.adjustSelection(withState : .Delete)
                    
                    calculator.control.layout(cancel : .Delete)
                    
                    calculator.selectionView.delete(state : .EntityTag)
                    calculator.equationField.inputView = calculator.selectionView
                    calculator.equationField.reloadInputViews()
                    
                    calculator.equationField.becomeFirstResponder()
                }
                
                //attributes
                deleteBtn.backgroundColor = .red
                
                return [deleteBtn]
            
            
            default : break
            }
            
        case calculator.modelList :
            switch calculator.selectedState
            {
            case .Equation, .SearchedEquation, .Value, .SearchedValue : return nil
            default :
                //button
                let tagOffBtn = UITableViewRowAction(style : .destructive, title : "#detach".local) { (action, _indexPath) in
                    //case
                    if calculator.entityState == .EntityEquation
                    {
                        calculator.equationSections[indexPath.section][indexPath.row].remove(tag : calculator.selectedTag!)
                        
                        if calculator.equationSections[indexPath.section].count == 1
                        {
                            calculator.equationSections[indexPath.section].remove(at : indexPath.row)
                            calculator.equationSections.remove(at : indexPath.section)
                            calculator.sectionIndexTitles.remove(at : indexPath.section)
                            calculator.modelList.deleteSections(IndexSet(integer : indexPath.section), with : .automatic)
                        }
                        else
                        {
                            calculator.equationSections[indexPath.section].remove(at : indexPath.row)
                            calculator.modelList.deleteRows(at : [indexPath], with : .fade)
                        }
                    }
                    else
                    {
                        calculator.valueSections[indexPath.section][indexPath.row].remove(tag : calculator.selectedTag!)
                        
                        if calculator.valueSections[indexPath.section].count == 1
                        {
                            calculator.valueSections[indexPath.section].remove(at : indexPath.row)
                            calculator.valueSections.remove(at : indexPath.section)
                            calculator.sectionIndexTitles.remove(at : indexPath.section)
                            calculator.modelList.deleteSections(IndexSet(integer : indexPath.section), with : .automatic)
                        }
                        else
                        {
                            calculator.valueSections[indexPath.section].remove(at : indexPath.row)
                            calculator.modelList.deleteRows(at : [indexPath], with : .fade)
                        }
                    }
                    
                    DM.saveContext()
                    calculator.entitySegment.activateLayout()
                    
                }
                
                //attributes
                tagOffBtn.backgroundColor = .red
                
                return [tagOffBtn]
                
            }
        
        default : break
        }
        return nil
    }
    
    func tableView(_ tableView : UITableView, commit editingStyle : UITableViewCellEditingStyle, forRowAt indexPath : IndexPath)
    {
        //delete
        if editingStyle == .delete
        {
            switch tableView
            {
            case calculator.recentList :
                SM.adjustSelection(withState : .Delete)
                
                calculator.control.layout(cancel : .Delete)
                
                switch calculator.recentState
                {
                case .RecentEquation :
                    calculator.equationSections[indexPath.section][indexPath.row].select()
                    calculator.selectionView.delete(state : .EntityEquation)
                
                case .RecentValue :
                    calculator.valueSections[indexPath.section][indexPath.row].select()
                    calculator.selectionView.delete(state : .EntityValue)
                
                default : return
                }
            
                calculator.equationField.inputView = calculator.selectionView
                calculator.equationField.reloadInputViews()
            
            case calculator.groupEntityList :
                SM.adjustSelection(withState : .Delete)
                
                calculator.control.layout(cancel : .Delete)
                
                switch calculator.groupState
                {
                case .GroupEquation :
                    calculator.equationSections[indexPath.section][indexPath.row].select()
                    calculator.selectionView.delete(state : .EntityEquation)
                
                case .GroupValue :
                    calculator.valueSections[indexPath.section][indexPath.row].select()
                    calculator.selectionView.delete(state : .EntityValue)
                
                case .GroupTag :
                    calculator.tagSections[indexPath.section][indexPath.row].select()
                    calculator.selectionView.delete(state : .EntityTag)
                
                default : return
                }
            
                calculator.equationField.inputView = calculator.selectionView
                calculator.equationField.reloadInputViews()
                
            case calculator.tagList :
                SM.adjustSelection(withState : .Delete)
                
                calculator.control.layout(cancel : .Delete)
                
                //select target tag
                calculator.tagSections[indexPath.section][indexPath.row].select()
                calculator.selectionView.delete(state : .EntityTag)
                
                calculator.equationField.inputView = calculator.selectionView
                calculator.equationField.reloadInputViews()
                
            case calculator.unitList :
                calculator.convertView.refreshLbl.isHidden = true
                
                //fetch target model
                let unit = calculator.selectedUnits[indexPath.row]
                unit.selected = false
                
                //remove unit from array
                calculator.selectedUnits.remove(at : calculator.selectedUnits.index(of : unit)!)
                
                //reload views
                UIView.animate(withDuration : 0.5, animations : {
                    calculator.unitList.deleteRows(at : [indexPath], with : .automatic)
                    
                }, completion : { (finished) in
                    if finished
                    {
                        calculator.unitList.reloadData()
                        calculator.convertView.refreshLbl.isHidden = false
                    }
                    
                })

            default : break
                
            }
        }
    }
    
    func tableView(_ tableView : UITableView, canMoveRowAt indexPath : IndexPath) -> Bool
    {
        if tableView == calculator.equationList
        {
            return true
        }
        return false
    }
    
    func tableView(_ tableView : UITableView, moveRowAt sourceIndexPath : IndexPath, to destinationIndexPath : IndexPath)
    {
        if tableView == calculator.equationList
        {
            let sourceRow = sourceIndexPath.row
            let targetRow = destinationIndexPath.row
            
            let equation = calculator.currentEquations[sourceRow]
            
            calculator.currentEquations.remove(at : sourceRow)
            calculator.currentEquations.insert(equation, at : targetRow)
            
            //reload
            calculator.equationList.reloadData()
            calculator.equationView.updateCount()
        }
    }
    
    
    //MARK: - ScrollView Delegate
    
    
    func scrollViewDidScroll(_ scrollView : UIScrollView)
    {
        switch scrollView
        {
        case calculator.recentList :
            if scrollView.contentOffset.y > 0
            {
                switch calculator.recentState
                {
                case .RecentEquation :
                    if calculator.recentEquations.count != 0
                    {
                        calculator.recentView.refreshLbl.textColor = .clear
                    }
                    
                case .RecentValue :
                    if calculator.recentValues.count != 0
                    {
                        calculator.recentView.refreshLbl.textColor = .clear
                    }
                    
                default : break
                }
            }
            else
            {
                let yOffset = abs(scrollView.contentOffset.y)
                if yOffset > 80
                {
                    calculator.recentList.setContentOffset(.zero, animated : false)
                    
                    //switch views
                    calculator.equationView.isHidden = true
                    calculator.operationView.isHidden = true
                    rootVC.line.isHidden = true
                    rootVC.view.addSubview(calculator.editView)
                    
                    //switch control
                    calculator.valueField.inputView = nil
                    calculator.valueField.layoutEntityInput()
                    
                    //case
                    switch calculator.recentState
                    {
                    case .RecentEquation    : calculator.control.layout(field : .CreateEquation)
                    case .RecentValue       : calculator.control.layout(field : .CreateValue)
                    default                 : break
                    }
                    
                    calculator.valueField.becomeFirstResponder()
                    calculator.valueField.reloadInputViews()
                    
                    //activate editView
                    calculator.editView.show()
                }
                else
                {
                    calculator.recentView.refreshLbl.textColor = yOffset == 0 ?
                    SM.defaultColor() : SM.draggedColor(withOffset : yOffset)
                }
            }
        
        case calculator.groupList :
            if !calculator.valueField.isFirstResponder && !calculator.manageEditing
            {
                if scrollView.contentOffset.y > 0
                {
                    if calculator.groups.count != 0
                    {
                        calculator.groupView.groupRefreshLbl.textColor = .clear
                    }
                }
                else
                {
                    let yOffset = abs(scrollView.contentOffset.y)
                    if yOffset > 80
                    {
                        calculator.groupList.setContentOffset(.zero, animated : false)
                        
                        //switch views
                        calculator.equationView.isHidden = true
                        calculator.operationView.isHidden = true
                        rootVC.line.isHidden = true
                        rootVC.view.addSubview(calculator.editView)
                        
                        //switch control
                        calculator.valueField.inputView = nil
                        calculator.valueField.layoutEntityInput()
                        calculator.control.layout(field : .CreateGroup)
                        
                        calculator.valueField.becomeFirstResponder()
                        calculator.valueField.reloadInputViews()
                        
                        //activate editView
                        calculator.editView.show()
                    }
                    else
                    {
                        calculator.groupView.groupRefreshLbl.textColor = yOffset == 0 ?
                        SM.defaultColor() : SM.draggedColor(withOffset : yOffset)
                    }
                }
            }
            
        case calculator.groupEntityList :
            if scrollView.contentOffset.y > 0
            {
                if let group = calculator.selectedGroup
                {
                    switch calculator.groupState
                    {
                    case .GroupEquation :
                        if group.equationCount() != 0
                        {
                            calculator.groupView.refreshLbl.textColor = .clear
                        }
                        
                    case .GroupValue :
                        if group.valueCount() != 0
                        {
                            calculator.groupView.refreshLbl.textColor = .clear
                        }
                        
                    case .GroupTag :
                        if group.tagCount() != 0
                        {
                            calculator.groupView.refreshLbl.textColor = .clear
                        }
                    
                    default : break
                    }
                }
            }
            else
            {
                let yOffset = abs(scrollView.contentOffset.y)
                
                if yOffset > 80
                {
                    calculator.groupEntityList.setContentOffset(.zero, animated : false)
                    
                    //switch views
                    calculator.equationView.isHidden = true
                    calculator.operationView.isHidden = true
                    rootVC.line.isHidden = true
                    rootVC.view.addSubview(calculator.editView)
                    
                    //switch control
                    calculator.valueField.inputView = nil
                    calculator.valueField.layoutEntityInput()
                    
                    //case
                    switch calculator.groupState
                    {
                    case .GroupEquation : calculator.control.layout(field : .CreateEquation)
                    case .GroupValue    : calculator.control.layout(field : .CreateValue)
                    case .GroupTag      : calculator.control.layout(field : .CreateTag)
                    default             : break
                    }
                    
                    calculator.valueField.becomeFirstResponder()
                    calculator.valueField.reloadInputViews()
                    
                    //activate editView
                    calculator.editView.show()
                }
                else
                {
                    calculator.groupView.refreshLbl.textColor = yOffset == 0 ?
                    SM.defaultColor() : SM.draggedColor(withOffset : yOffset)
                }
            }
        
        case calculator.unitList :
            if scrollView.contentOffset.y > 0
            {
                if calculator.selectedUnitGroup?.units.count != 0
                {
                    calculator.convertView.refreshLbl.textColor = .clear
                }
            }
            else
            {
                let yOffset = abs(scrollView.contentOffset.y)
                
                if calculator.fieldState == .None ? yOffset > 70 : yOffset > 60
                {
                    if calculator.selectedUnitGroup!.name == "#currency".local
                    {
                        if Reachability.isConnectedToNetwork() == false
                        {
                            if let lastCurrency = calculator.setting!.lastCurrency
                            {
                                //old currency data alert
                                calculator.dateFormatter.dateFormat = "YY-MM-dd  HH : mm"
                                let lastUpdateStr = calculator.dateFormatter.string(from : lastCurrency)
                                let message = "#oldCurrency".local + lastUpdateStr + " ?"
                                
                                //prepare alert
                                let alert = UIAlertController(title : "#noConnection".local, message : message,
                                                              preferredStyle : .alert)
                                
                                //add alert actions
                                alert.addAction(UIAlertAction(title : "#continue".local, style : .default) { action in
                                    //validate
                                    if rootVC.navigationController?.topViewController is UnitPickerVC
                                    {
                                        return
                                    }
                                    
                                    //continue with unitPicker
                                    calculator.unitList.setContentOffset(.zero, animated : false)
                                    
                                    //push unitPickerVC
                                    let unitPickerVC = UnitPickerVC()
                                    rootVC.navigationController?.pushModally(VC : unitPickerVC)
                                    calculator.equationView.isHidden = true
                                })
                                alert.addAction(UIAlertAction(title : "#cancel".local, style : .destructive) { action in
                                    return
                                })
                                
                                calculator.viewState == .Root || calculator.viewState == .RootSearch ?
                                rootVC.present(alert, animated : true) : calculator.manageVC!.present(alert, animated : true)
                            }
                        }
                        else
                        {
                            //validate
                            if rootVC.navigationController?.topViewController is UnitPickerVC
                            {
                                return
                            }
                            
                            calculator.unitList.setContentOffset(.zero, animated : false)
                            
                            //push unitPickerVC
                            let unitPickerVC = UnitPickerVC()
                            rootVC.navigationController?.pushModally(VC : unitPickerVC)
                            calculator.equationView.isHidden = true
                        }
                    }
                    else
                    {
                        //validate
                        if rootVC.navigationController?.topViewController is UnitPickerVC
                        {
                            return
                        }
                        
                        calculator.unitList.setContentOffset(.zero, animated : false)
                        
                        //push unitPickerVC
                        let unitPickerVC = UnitPickerVC()
                        rootVC.navigationController?.pushModally(VC : unitPickerVC)
                        calculator.equationView.isHidden = true
                    }
                }
                else
                {
                    calculator.convertView.refreshLbl.textColor = yOffset == 0 ?
                    SM.defaultColor() : SM.draggedColor(withOffset : yOffset)
                }
            }
            
        case calculator.tagList :
            if calculator.recentState == .RecentTag && calculator.equationField.isFirstResponder
            {
                if scrollView.contentOffset.y > 0
                {
                    if calculator.tags.count != 0
                    {
                        calculator.recentView.refreshLbl.textColor = .clear
                    }
                    else
                    {
                        break
                    }
                }
                else
                {
                    let yOffset = abs(scrollView.contentOffset.y)
                    if yOffset > 80
                    {
                        calculator.tagList.setContentOffset(.zero, animated : false)
                        
                        //switch views
                        calculator.equationView.isHidden = true
                        calculator.operationView.isHidden = true
                        rootVC.line.isHidden = true
                        rootVC.view.addSubview(calculator.editView)
                        
                        //switch control
                        calculator.valueField.inputView = nil
                        calculator.valueField.layoutEntityInput()
                        
                        //layout
                        calculator.control.layout(field : .CreateTag)
                        
                        calculator.valueField.becomeFirstResponder()
                        calculator.valueField.reloadInputViews()
                        
                        //activate editView
                        calculator.editView.show()
                    }
                    else
                    {
                        calculator.recentView.refreshLbl.textColor = yOffset == 0 ?
                        SM.defaultColor() : SM.draggedColor(withOffset : yOffset)
                    }
                }
            }

        default : break
        }
        
    }
    
    
}
