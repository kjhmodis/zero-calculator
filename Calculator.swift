
import Foundation
import UIKit
import CoreData
import MessageUI
import AVFoundation
import Photos

/***********************/
/** zero engine ver 1 **/
/***********************/


//MARK: -


class Calculator : NSObject, MFMailComposeViewControllerDelegate, UIPageViewControllerDelegate, ButtonDelegate
{
    //MARK: - Instance
    
    //singleton
    static let sharedInstance       = Calculator()
    
    /* ViewControllers */
    var settingVC                   : SettingVC?
    var manageVC                    : ManageVC?
    
    /* Models */
    var setting                     : Setting?
    let numberFormatter             : NumberFormatter
    let dateFormatter               : DateFormatter
    var dateComponents              : DateComponents
    let calendar                    : NSCalendar
    var audioPlayer                 : AVAudioPlayer
    
    var shortCutCreate              : Bool
    var manageDisplayed             : Bool
    var manageEditing               : Bool
    var manageGrouping              : Bool
    
    var controlButtons              : [Button]
    var calculatorButtons           : [Button]
    var selectionButtons            : [Button]
    var extensionButtons            : [Button]
    var entityButtons               : [Button]
    var fieldButtons                : [Button]
    var keyboardButtons             : [ShadowButton]
    
    var selectedFont                : Font
    var selectedTheme               : Theme
    
    //operation
    var groups                      : [Group]
    
    var equations                   : [Equation]
    var currentEquations            : [Equation]
    var searchedEquations           : [Equation]
    var selectedEquations           : [Equation]
    var recentEquations             : [Equation]
    
    var values                      : [Value]
    var searchedValues              : [Value]
    var selectedValues              : [Value]
    var recentValues                : [Value]
    
    var tags                        : [Tag]
    var searchedTags                : [Tag]
    var selectedTags                : [Tag]
    
    var filters                     : [Filter]
    var unitGroups                  : [UnitGroup]
    
    var groupSections               : [[Group]]
    var equationSections            : [[Equation]]
    var valueSections               : [[Value]]
    var tagSections                 : [[Tag]]
    var currencySections            : [[Unit]]
    
    var selectedUnits               : [Unit]
    var themes                      : [Theme]
    var fonts                       : [Font]
    
    var sectionIndexTitles          : [String]
    var entityIndexTitles           : [String]
    var selectionTitles             : [String]

    var entityValueStr              : String
    var entityGroup                 : Group?
    var entityUnit                  : Unit?
    var entityTags                  : [Tag]
    
    var manageSelectedGroup         : Group?
    var selectedGroup               : Group?
    var selectedUnitGroup           : UnitGroup?
    
    var currentEquation             : Equation?
    var highlightedEquation         : Equation?
    var selectedEquation            : Equation?
    var selectedSearchedEquation    : Equation?
    var wrongEquation               : Equation?
    
    var highlightedValue            : Value?
    var selectedValue               : Value?
    var selectedSearchedValue       : Value?
    var valueBeforeEquation         : Value?
    
    var highlightedOperation        : Operation?
    var selectedOperation           : Operation?
    var operationBeforeEquation     : Operation?
    
    var selectedTag                 : Tag?
    
    var controlState                = ControlState.Calculator
    var settingState                = SettingState.Base
    
    var viewState                   = ViewState.Root
    var operationState              = OperationState.ValueTyping
    var highlightedState            = HighlightedState.Value
    var selectedState               = SelectedState.Value
    var adjustState                 = AdjustState.Equation
    var blurState                   = BlurState.EquationList
    var fieldState                  = FieldState.None
    var selectionListState          = SelectionListState.AttachPhoto
    var recentState                 = SelectionState.RecentValue
    var groupState                  = SelectionState.GroupValue
    var entityState                 = SelectionState.EntityValue
    var selectFrom                  = SelectFrom.Operation
    
    /* ListViews */
    var equationList                : ListView
    var modelList                   : ListView
    var metaList                    : ListView
    var recentList                  : ListView
    var filterList                  : ListView
    var manageList                  : ListView
    var groupList                   : ListView
    var groupEntityList             : ListView
    var tagList                     : ListView
    var unitGroupList               : ListView
    var unitList                    : ListView
    var unitPickerList              : ListView
    var settingList                 : ListView
    var settingDepthList            : ListView
    var settingInDepthList          : ListView
    var selectionList               : ListView
    
    /* ListCells */
    var upperModelCell              : ModelCell?
    var lowerModelCell              : ModelCell?
    
    /* CollectionViews */
    var operationView               : CollectionView
    var searchView                  : CollectionView
    var themeView                   : CollectionView
    
    /* UpperViews */
    var equationView                : EquationView
    var editView                    : EditView
    var infoView                    : InfoView
    var entitySegment               : EntitySegment
    
    /* LowerViews */
    var control                     : Control
    var selectionView               : SelectionView
    var calculatorView              : CalculatorView
    var recentView                  : RecentView
    var groupView                   : GroupView
    var convertView                 : ConvertView
    
    /* etc */
    var equationField               : TextField
    var valueField                  : TextField
    var blurView                    : BlurView
    
    override init()
    {
        /* model */
        
        //members
        self.numberFormatter        = NumberFormatter()
        self.dateFormatter          = DateFormatter()
        self.dateComponents         = DateComponents()
        self.calendar               = NSCalendar(calendarIdentifier : .gregorian)!
        self.audioPlayer            = AVAudioPlayer()
        self.entityValueStr         = "0"
        
        self.shortCutCreate         = false
        self.manageDisplayed        = false
        self.manageEditing          = false
        self.manageGrouping         = false
        
        self.groups                 = [Group]()
        
        self.equations              = [Equation]()
        self.currentEquations       = [Equation]()
        self.searchedEquations      = [Equation]()
        self.selectedEquations      = [Equation]()
        self.recentEquations        = [Equation]()
        
        self.values                 = [Value]()
        self.searchedValues         = [Value]()
        self.selectedValues         = [Value]()
        self.recentValues           = [Value]()
        
        self.filters                = [Filter]()
        self.unitGroups             = [UnitGroup]()
        self.selectedUnits          = [Unit]()
        self.themes                 = [Theme]()
        self.fonts                  = [Font]()
        
        self.tags                   = [Tag]()
        self.searchedTags           = [Tag]()
        self.selectedTags           = [Tag]()
        self.entityTags             = [Tag]()
        
        self.groupSections          = [[Group]]()
        self.equationSections       = [[Equation]]()
        self.valueSections          = [[Value]]()
        self.tagSections            = [[Tag]]()
        self.currencySections       = [[Unit]]()
        
        self.sectionIndexTitles     = [String]()
        self.entityIndexTitles      = [String]()
        self.selectionTitles        = [String]()
        
        self.controlButtons         = [Button]()
        self.calculatorButtons      = [Button]()
        self.selectionButtons       = [Button]()
        self.extensionButtons       = [Button]()
        
        self.entityButtons          = [Button]()
        
        self.fieldButtons           = [Button]()
        self.keyboardButtons        = [ShadowButton]()
        
        self.selectedFont           = DM.fetchFonts().count != 0 ?
                                      DM.fetchFonts().filter({ $0.selected == true }).first! :
                                      DM.createInitialFonts()[0]
        
        self.selectedTheme          = DM.fetchThemes().count != 0 ?
                                      DM.fetchThemes().filter({ $0.selected == true }).first! :
                                      DM.createInitialThemes()[0]
        
        //listViews
        self.equationList           = ListView(frame : .zero, style : .grouped)
        self.modelList              = ListView(frame : .zero, style : .grouped)
        self.metaList               = ListView(frame : .zero, style : .grouped)
        self.recentList             = ListView(frame : .zero, style : .grouped)
        self.filterList             = ListView(frame : .zero, style : .grouped)
        self.manageList             = ListView(frame : .zero, style : .grouped)
        self.groupList              = ListView(frame : .zero, style : .grouped)
        self.groupEntityList        = ListView(frame : .zero, style : .grouped)
        self.tagList                = ListView(frame : .zero, style : .grouped)
        self.unitGroupList          = ListView(frame : .zero, style : .grouped)
        self.unitList               = ListView(frame : .zero, style : .grouped)
        self.unitPickerList         = ListView(frame : .zero, style : .grouped)
        self.settingList            = ListView(frame : .zero, style : .grouped)
        self.settingDepthList       = ListView(frame : .zero, style : .grouped)
        self.settingInDepthList     = ListView(frame : .zero, style : .grouped)
        self.selectionList          = ListView(frame : .zero, style : .grouped)
        
        //collectionViews
        self.operationView          = CollectionView(frame : .zero, collectionViewLayout : OperationViewLayout())
        self.searchView             = CollectionView(frame : .zero, collectionViewLayout : SearchViewLayout())
        self.themeView              = CollectionView(frame : .zero, collectionViewLayout : ThemeViewLayout())
        
        //upperViews
        self.equationView           = EquationView(frame        : .zero)
        self.editView               = EditView(frame            : .zero)
        self.infoView               = InfoView(frame            : .zero)
        self.entitySegment          = EntitySegment(frame       : .zero)
        
        //lowerViews
        self.control                = Control(frame             : .zero)
        self.selectionView          = SelectionView(frame       : .zero)
        self.calculatorView         = CalculatorView(frame      : .zero)
        self.recentView             = RecentView(frame          : .zero)
        self.groupView              = GroupView(frame           : .zero)
        self.convertView            = ConvertView(frame         : .zero)
        
        //fields
        self.equationField          = TextField(frame : .zero)
        self.valueField             = TextField(frame : .zero)
        
        //etc
        self.blurView               = BlurView(frame : UIScreen.main.bounds)
        
        super.init()
    }
    
    func prepareDefaults()
    {
        /* fetch defaults */
        /* setting | filters | customFonts | themes | tags */
        
        //fetch setting
        if let setting = DM.fetchSetting()
        {
            self.setting = setting
        }
        else
        {
            self.setting = DM.createInitialSetting()
        }
        
        //fetch filters
        if DM.fetchFilters().count == 0
        {
            self.filters = DM.createInitialFilters()
        }
        else
        {
            self.filters = DM.fetchFilters()
        }
        
        //fetch unitGroups
        if DM.fetchUnitGroups().count == 0
        {
            self.unitGroups = DM.createInitialUnitGroups()
        }
        else
        {
            self.unitGroups = DM.fetchUnitGroups()
        }
        
        self.selectedUnitGroup = self.unitGroups[1]
        self.selectedUnits = self.selectedUnitGroup!.fetchUnits().filter({ $0.selected.boolValue == true })
        
        //fetch themes
        if DM.fetchThemes().count == 0
        {
            self.themes = DM.createInitialThemes()
        }
        else
        {
            self.themes = DM.fetchThemes()
        }
        
        //fetch fonts
        if DM.fetchFonts().count == 0
        {
            self.fonts = DM.createInitialFonts()
        }
        else
        {
            self.fonts = DM.fetchFonts()
        }
        
        /* init */
        
        //numberFormatter
        self.numberFormatter.numberStyle            = .decimal
        self.numberFormatter.maximumFractionDigits  = self.setting!.decimalLimit.intValue
        self.numberFormatter.usesSignificantDigits  = false
        self.numberFormatter.locale                 = Locale(identifier : "en")
        
        //audioPlayer
        if self.setting!.playSound == true
        {
            self.prepareSoundPlay()
        }
        
        /** register reuse identifers (listView) **/
        
        let lists = [self.equationList, self.metaList, self.modelList, self.recentList, self.groupEntityList, self.tagList,
                     self.manageList, self.filterList, self.groupList, self.unitGroupList, self.unitList, self.unitPickerList,
                     self.settingList, self.settingDepthList, self.settingInDepthList, self.selectionList]
        
        for list in lists
        {
            //register cells
            switch list
            {
            case self.equationList :
                list.register(EquationCell.self,    forCellReuseIdentifier : CellID.EquationList.rawValue)
                
            case self.metaList :
                list.register(MetaCell.self,        forCellReuseIdentifier : CellID.MetaListI.rawValue)
                list.register(MetaCell.self,        forCellReuseIdentifier : CellID.MetaListE.rawValue)
                
            case self.modelList :
                list.register(EquationCell.self,    forCellReuseIdentifier : CellID.ModelListE.rawValue)
                list.register(EntityCell.self,      forCellReuseIdentifier : CellID.ModelListV.rawValue)
                
            case self.recentList :
                list.register(EquationCell.self,    forCellReuseIdentifier : CellID.RecentListE.rawValue)
                list.register(EntityCell.self,      forCellReuseIdentifier : CellID.RecentListV.rawValue)
                
            case self.groupEntityList :
                list.register(EquationCell.self,    forCellReuseIdentifier : CellID.GroupEntityListE.rawValue)
                list.register(EntityCell.self,      forCellReuseIdentifier : CellID.GroupEntityListV.rawValue)
                list.register(EntityCell.self,      forCellReuseIdentifier : CellID.GroupEntityListT.rawValue)
                
            case self.tagList :
                list.register(EntityCell.self,      forCellReuseIdentifier : CellID.TagList.rawValue)
                
            case self.manageList :
                list.register(EquationCell.self,    forCellReuseIdentifier : CellID.ManageListE.rawValue)
                list.register(EntityCell.self,      forCellReuseIdentifier : CellID.ManageListG.rawValue)
                list.register(EntityCell.self,      forCellReuseIdentifier : CellID.ManageListV.rawValue)
                list.register(EntityCell.self,      forCellReuseIdentifier : CellID.ManageListT.rawValue)
                
            case self.filterList :
                list.register(EntityCell.self,      forCellReuseIdentifier : CellID.FilterList.rawValue)
                
            case self.groupList :
                list.register(EntityCell.self,      forCellReuseIdentifier : CellID.GroupList.rawValue)
                list.register(EntityCell.self,      forCellReuseIdentifier : CellID.GroupListNone.rawValue)
                
            case self.unitGroupList :
                list.register(EntityCell.self,      forCellReuseIdentifier : CellID.UnitGroupList.rawValue)
                
            case self.unitList :
                list.register(EntityCell.self,      forCellReuseIdentifier : CellID.UnitList.rawValue)
                
            case self.unitPickerList :
                list.register(EntityCell.self,      forCellReuseIdentifier : CellID.UnitPickerList.rawValue)
                
            case self.settingList :
                list.register(SettingCell.self,     forCellReuseIdentifier : CellID.SettingList.rawValue)
                
            case self.settingDepthList :
                list.register(SettingCell.self,     forCellReuseIdentifier : CellID.SettingDepthList.rawValue)
                
            case self.settingInDepthList :
                list.register(SettingCell.self,     forCellReuseIdentifier : CellID.SettingInDepthList.rawValue)
                
            case self.selectionList :
                list.register(SelectionCell.self,   forCellReuseIdentifier : CellID.SelectionList.rawValue)
                
            default : break
            }
            
            //register header & footer
            list.register(Header.self, forHeaderFooterViewReuseIdentifier : "header")
            list.register(Footer.self, forHeaderFooterViewReuseIdentifier : "footer")
        }
        
        self.filterList.isScrollEnabled = false
        
        //set defaultValue
        self.currentEquation = DM.fetchInventoryEquation()
        self.currentEquations.append(self.currentEquation!)
        self.equationView.updateCount()
        
        //highlight initial value
        self.currentEquation!.firstValue()?.highlight()
        
        /* upperViews */
        
        //positions
        let equationViewPos             = CGPoint.zero
        let operationViewPos            = CGPoint(x : 0, y : statusBarHeight + (pureUpperHeight * 0.2))
        let searchViewPos               = CGPoint(x : 0, y : statusBarHeight + (pureUpperHeight * 0.7))
        let themePos                    = CGPoint(x : 0, y : topBarHeight)
        
        //sizes
        let equationViewSize            = CGSize(width : refWidth, height : statusBarHeight + (pureUpperHeight * 0.2) - 1)
        let operationViewSize           = CGSize(width : refWidth, height : pureUpperHeight * 0.5)
        let searchViewSize              = CGSize(width : refWidth, height : (pureUpperHeight * 0.3) + 1)
        
        let editViewSize                = CGSize(width : refWidth, height : refHeight - (keyboardHeight + ctrlBtnHeight * 2))
        let infoViewSize                = CGSize(width : refWidth, height : refHeight - ((btnLength * 3) + ctrlBtnHeight))
        let themeViewSize               = CGSize(width : refWidth, height : (refHeight - topBarHeight) * 0.6)
        
        //init
        self.equationView.frame         = CGRect(origin : equationViewPos,      size : equationViewSize)
        self.operationView.frame        = CGRect(origin : operationViewPos,     size : operationViewSize)
        self.searchView.frame           = CGRect(origin : searchViewPos,        size : searchViewSize)
        self.editView.frame             = CGRect(origin : .zero,                size : editViewSize)
        self.infoView.frame             = CGRect(origin : .zero,                size : infoViewSize)
        self.themeView.frame            = CGRect(origin : themePos,             size : themeViewSize)
        
        /* lowerViews */
        
        //sizes
        let calculatorHeight            = isIphoneX ? (btnLength * 4) + bottomBuffer : btnLength * 4
        let recentHeight                = isIphoneX ? ((btnLength * 4) - ctrlBtnHeight) + bottomBuffer :
                                                      (btnLength * 4) - ctrlBtnHeight
        
        let screenSize                  = CGSize(width : refWidth,              height : refHeight)
        let controlSize                 = CGSize(width : refWidth,              height : btnLength)
        let calculatorViewSize          = CGSize(width : refWidth,              height : calculatorHeight)
        let recentViewSize              = CGSize(width : refWidth,              height : recentHeight)
        
        let recentListSize              = CGSize(width : refWidth,              height : recentHeight)
        let groupListSize               = CGSize(width : (refWidth * 0.4) - 1,  height : recentHeight)
        let groupEntityListSize         = CGSize(width : (refWidth * 0.6) - 1,  height : recentHeight)
        let unitGroupListSize           = CGSize(width : (refWidth * 0.2) - 1,  height : calculatorHeight)
        let unitListSize                = CGSize(width : refWidth * 0.8,        height : calculatorHeight)
        
        //init
        self.control.frame              = CGRect(origin : .zero, size : controlSize)
        self.selectionView.frame        = CGRect(origin : .zero, size : calculatorViewSize)
        self.calculatorView.frame       = CGRect(origin : .zero, size : calculatorViewSize)
        self.convertView.frame          = CGRect(origin : .zero, size : calculatorViewSize)
        self.recentView.frame           = CGRect(origin : .zero, size : recentViewSize)
        self.groupView.frame            = CGRect(origin : .zero, size : recentViewSize)
        
        /* special */
        self.blurView.frame             = CGRect(origin : .zero, size : screenSize)
        
        /* listViews */
        self.equationList.frame         = CGRect(origin : .zero, size : screenSize)
        self.recentList.frame           = CGRect(origin : .zero, size : recentListSize)
        self.manageList.frame           = CGRect(origin : .zero, size : screenSize)
        self.groupList.frame            = CGRect(origin : .zero, size : groupListSize)
        self.groupEntityList.frame      = CGRect(origin : .zero, size : groupEntityListSize)
        self.tagList.frame              = CGRect(origin : .zero, size : recentListSize)
        
        self.unitGroupList.frame        = CGRect(origin : .zero, size : unitGroupListSize)
        self.unitList.frame             = CGRect(origin : .zero, size : unitListSize)
        self.unitPickerList.frame       = CGRect(origin : .zero, size : screenSize)
        self.settingList.frame          = CGRect(origin : .zero, size : screenSize)
        self.settingDepthList.frame     = CGRect(origin : .zero, size : screenSize)
        self.settingInDepthList.frame   = CGRect(origin : .zero, size : screenSize)
        
        //prepareDefaults
        self.control.prepareDefaults()
        self.equationField.prepareDefaults()
        self.valueField.prepareDefaults()
        
        self.equationView.prepareDefaults()
        self.editView.prepareDefaults()
        self.infoView.prepareDefaults()
        self.entitySegment.prepareDefaults()
        self.selectionView.prepareDefaults()
        self.calculatorView.prepareDefaults()
        self.recentView.prepareDefaults()
        self.groupView.prepareDefaults()
        self.convertView.prepareDefaults()
        self.blurView.prepareDefaults()
        
        //activate collectionViews
        self.operationView.activateOperation()
        self.searchView.activateSearch()
        self.themeView.activateTheme()
        
        //update calculate
        self.calculate(equation : self.currentEquation!)
        
        //fetch
        self.groups     = DM.fetchAllGroups()
        self.equations  = DM.fetchAllEquations()
        self.values     = DM.fetchAllValues()
        self.tags       = DM.fetchAllTags()
        
        //add current equation and starting value
        if !self.equations.contains(self.currentEquation!)
        {
            self.equations.append(self.currentEquation!)
        }
        if !self.values.contains(self.currentEquation!.firstValue()!)
        {
            self.values.append(self.currentEquation!.firstValue()!)
        }
        if self.groups.count != 0
        {
            self.selectedGroup = self.groups[0]
        }
        
        //validate menu display
        self.checkEnglishOptionDisplay()
        
        NotificationCenter.default.addObserver(self,
                                               selector : #selector(self.keyboardWillChangeFrame(withNotification:)),
                                               name : .UIKeyboardWillChangeFrame,
                                               object : nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector : #selector(self.keyboardDidChangeFrame(withNotification:)),
                                               name : .UIKeyboardDidChangeFrame,
                                               object : nil)
        
        //default condition
        self.equationField.activateEquationField()
        
        self.equationField.inputView          = self.calculatorView
        self.equationField.inputAccessoryView = self.control
        
        self.control.layout(control : .Calculator)
        
        self.equationField.reloadInputViews()
        self.equationField.becomeFirstResponder()
        
        
    }
    
    
    //MARK: - Common
    
    
    @objc func keyboardWillChangeFrame(withNotification notification : Notification)
    {
        //adjust searchView
        if self.equationField.isFirstResponder
        {
            if self.viewState == .Root
            {
                if let size = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                {
                    UIView.performWithoutAnimation
                    {
                        let searchY                     = refHeight - (size.height + self.searchView.bounds.height) + 1
                        self.searchView.frame.origin.y  = searchY
                    }
                }
            }
        }
        
        //adjust editView
        if self.valueField.isFirstResponder
        {
            switch self.fieldState
            {
            case .CreateEquation, .EditEquation, .CreateValue, .EditValue :
                if let size = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                {
                    UIView.performWithoutAnimation
                    {
                        let adjustedEntityHeight = refHeight - (statusBarHeight + self.metaList.bounds.height + size.height)
                        self.editView.entityView.frame.size = CGSize(width : self.editView.entityView.frame.size.width,
                                                                     height : adjustedEntityHeight)
                        self.metaList.frame.origin = CGPoint(x : 0,
                                                             y : statusBarHeight + self.editView.entityView.frame.size.height)
                        
                        self.editView.entityView.reloadData()
                    }
                }
                
            default : break
            }
        }
        
        //adjust list
        if (self.viewState == .Manage || self.viewState == .ManageSearch) && self.valueField.isFirstResponder
        {
            if let size = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            {
                //case (on search)
                if self.viewState == .ManageSearch
                {
                    UIView.performWithoutAnimation
                    {
                        //adjust rects
                        let leftOver = refHeight - size.height
                        let targetHeight = leftOver - (statusBarHeight + self.valueField.frame.height + self.entitySegment.frame.height)
                        self.manageList.frame.size = CGSize(width : refWidth, height : targetHeight)
                    }
                }
            }
        }
    }
    
    @objc func keyboardDidChangeFrame(withNotification notification : Notification)
    {
        self.keyboardWillChangeFrame(withNotification : notification)
    }
    
    func checkEnglishOptionDisplay()
    {
        if let langCode = Locale.current.languageCode
        {
            switch langCode
            {
            case "ko", "nl", "fr", "de", "it", "ja", "ru", "zh", "es", "sv",
                 "th", "vi", "pt", "id", "ms", "tr", "da", "el", "fi", "nb" : return
            default : collection.settingDepthItems[0].remove(at : 0)
            }
        }
    }
    
    func notify(withMessage message : String)
    {
        //prepare
        let refHeight                       = self.manageEditing ? topBarHeight : self.equationView.bounds.height
        
        let notifySize                      = CGSize(width : refWidth, height : refHeight)
        let notifyLbl                       = UILabel(frame : CGRect(origin : .zero, size : notifySize))
        
        //model
        notifyLbl.text                      = message
        
        //attributes
        notifyLbl.font                      = SM.defaultFont(withHeight : refHeight * 0.3)
        notifyLbl.backgroundColor           = SM.selectedBGColor()
        notifyLbl.textColor                 = SM.selectedTitleColor()
        notifyLbl.textAlignment             = .center
        notifyLbl.lineBreakMode             = .byWordWrapping
        notifyLbl.numberOfLines             = 0
        notifyLbl.adjustsFontSizeToFitWidth = true
        
        //prepare animation
        notifyLbl.alpha                     = 0
        
        //animate
        UIView.animate(withDuration : 0.25, animations :
        {
            appDelegate.window?.addSubview(notifyLbl)
            notifyLbl.alpha                 = 1
            
        },
        completion : { (completed) in
            UIView.animate(withDuration : 0.25, delay : 0.7, options : .curveEaseOut, animations :
            {
                notifyLbl.alpha             = 0
            },
            completion : nil)
            
        })
    }
    
    func equalUnitGroup(forValues values : [Value]) -> Bool
    {
        //prepare
        var unitGroups = [UnitGroup]()
        for value in values
        {
            if let unit = value.unit
            {
                for unitGroup in self.unitGroups
                {
                    if unitGroup.fetchUnits().contains(unit)
                    {
                        unitGroups.append(unitGroup)
                    }
                }
            }
        }
        
        //validate
        if unitGroups.count == values.count && unitGroups.count != 0 && values.count != 0
        {
            let firstUnitGroup = unitGroups.first!
            let comparants = unitGroups.dropFirst()
            
            for unitGroup in comparants
            {
                if unitGroup != firstUnitGroup
                {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    func sectionIndex(forDate date : Date) -> Int
    {
        //model
        let cal = Calendar.current
        let now = Date()
        let interval = date.timeIntervalSince(now)
        let gap = interval / 86400

        //compare
        switch gap
        {
        case -1         ..< -0      : //T
            return cal.component(.day, from : date) != cal.component(.day, from : now) ? 1 : 0
            
        case -2         ..< -1      : //Y
            self.dateComponents.day = -1
            let yesterday = cal.date(byAdding : self.dateComponents, to : now)
            return cal.component(.day, from : date) != cal.component(.day, from : yesterday!) ? 2 : 1
            
        case -7         ..< -2      : return 2 //1W
        case -14        ..< -7      : return 3 //2W
        case -31        ..< -14     : return 4 //1M
        case -93        ..< -31     : return 5 //3M
        case -186       ..< -93     : return 6 //6M
        case -365       ..< -186    : return 7 //1Y
        case -3649635   ..< -365    : return 8 //~
        default                     : return cal.component(.day, from : date) != cal.component(.day, from : now) ? 9 : 0 //F
        }
        
    }
    
    func fetchRecent()
    {
        //fetch target values (filtered)
        self.recentEquations = self.equations.filter({ (equation) -> Bool in
            let hasValue = equation.value != 0
            return hasValue
        })
        self.recentValues = self.values.filter({ (value) -> Bool in
            let hasName = value.name != ""
            let hasValue = value.value != 0
            return hasName || hasValue
        })
        
        //sort
        self.recentEquations    = self.recentEquations.sorted(by : { $0.createdDate > $1.createdDate })
        self.recentValues       = self.recentValues.sorted(by : { $0.createdDate > $1.createdDate })
        
        //limit to 200
        var equations   = [Equation]()
        var values      = [Value]()
        
        //iterate
        for equation in self.recentEquations
        {
            if equations.count <= 200
            {
                equations.append(equation)
            }
            else
            {
                break
            }
        }
        
        //iterate
        for value in self.recentValues
        {
            if values.count <= 200
            {
                values.append(value)
            }
            else
            {
                break
            }
        }
        
        //update
        self.recentEquations    = equations
        self.recentValues       = values
    }
    
    func applyFilters()
    {
        //case
        if self.setting!.filterAscend == true
        {
            switch self.manageDisplayed ? self.entityState : self.recentState
            {
            case .EntityEquation, .RecentEquation :
                for i in 0..<self.equationSections.count
                {
                    self.equationSections[i] = self.equationSections[i].sorted(by :
                        Equation.nameCompare,
                        Equation.valueCompare,
                        Equation.viewCompare,
                        Equation.createdDateCompare,
                        Equation.modifiedDateCompare,
                        Equation.recentDateCompare
                    )
                }
                
            case .EntityValue, .RecentValue :
                for i in 0..<self.valueSections.count
                {
                    self.valueSections[i] = self.valueSections[i].sorted(by :
                        Value.nameCompare,
                        Value.valueCompare,
                        Value.viewCompare,
                        Value.createdDateCompare,
                        Value.modifiedDateCompare,
                        Value.recentDateCompare
                    )
                }
                
            default : return
            }
        }
        else
        {
            switch manageDisplayed ? self.entityState : self.recentState
            {
            case .EntityEquation, .RecentEquation :
                for i in 0..<self.equationSections.count
                {
                    self.equationSections[i] = self.equationSections[i].sorted(by :
                        ComparisonResult.flip <<< Equation.nameCompare,
                        ComparisonResult.flip <<< Equation.valueCompare,
                        ComparisonResult.flip <<< Equation.viewCompare,
                        ComparisonResult.flip <<< Equation.createdDateCompare,
                        ComparisonResult.flip <<< Equation.modifiedDateCompare,
                        ComparisonResult.flip <<< Equation.recentDateCompare
                    )
                }
                
            case .EntityValue, .RecentValue :
                for i in 0..<self.valueSections.count
                {
                    self.valueSections[i] = self.valueSections[i].sorted(by :
                        ComparisonResult.flip <<< Value.nameCompare,
                        ComparisonResult.flip <<< Value.valueCompare,
                        ComparisonResult.flip <<< Value.viewCompare,
                        ComparisonResult.flip <<< Value.createdDateCompare,
                        ComparisonResult.flip <<< Value.modifiedDateCompare,
                        ComparisonResult.flip <<< Value.recentDateCompare
                    )
                }
                
            default : return
            }
        }
        
        manageDisplayed ? self.manageList.reloadData() : self.recentList.reloadData()
        
    }
    
    func checkNetworkStatus()
    {
        //connection not available
        if Reachability.isConnectedToNetwork() == false
        {
            /* validate */
            
            //has no previous data
            if self.setting!.lastCurrency == nil
            {
                self.unitList.isHidden                  = true
                self.convertView.refreshLbl.isHidden    = true
                self.convertView.statusLbl.isHidden     = false
            }
            //has previous data
            else
            {
                self.unitList.isHidden                  = false
                self.convertView.refreshLbl.isHidden    = false
                self.convertView.statusLbl.isHidden     = true
            }
        }
        //connection available
        else
        {
            self.convertView.refreshLbl.isHidden    = false
            self.unitList.isHidden                  = true
            self.convertView.refreshLbl.text        = "#fetching".local
            
            //has previous data
            if let lastCurrency = self.setting!.lastCurrency
            {
                //set 1 minute interval
                let secondsBetween = abs(Int(lastCurrency.timeIntervalSince(Date())))
                if secondsBetween > 60
                {
                    //fetch
                    self.fetchCurrencyRate()
                }
                else
                {
                    self.convertView.refreshLbl.isHidden    = false
                    self.unitList.isHidden                  = false
                    self.convertView.refreshLbl.text        = "#pullAddUnit".local
                    return
                }
            }
            else
            {
                //initial fetch
                self.fetchCurrencyRate()
            }
            
            self.convertView.statusLbl.isHidden = true
        }
    
    }
    
    func fetchCurrencyRate()
    {
        //prepare api access
        let accessKey = "9a18132602401a961f3a6335c4329f5b"
        let rateURL = URL(string : "http://apilayer.net/api/live?access_key=\(accessKey)&format=1")
        
        var rates = [Rate]()
        
        //fetch rate
        URLSession.shared.dataTask(with : rateURL!) { (data, response, error) in
            if error != nil
            {
                return
            }
            else
            {
                //de-serialize json
                if let jsonData = try? JSONSerialization.jsonObject(with : data!, options : .allowFragments) as! [String : Any]
                {
                    let currencies = jsonData["quotes"] as! [String : NSNumber]
                    
                    for currency in currencies
                    {
                        let symbol  = String(currency.key[currency.key.index(currency.key.startIndex, offsetBy : 3)
                                      ..< currency.key.endIndex])
                        let ratio   = symbol != "USD" ?  1 / currency.value.decimalValue : 1
                        let rate    = Rate(symbol : String(symbol), ratio : NSDecimalNumber(decimal : ratio))
                        
                        rates.append(rate)
                    }
                }
            }
            
            //fetch main queue
            DispatchQueue.main.async
            {
                //sort alphabetically
                rates = rates.sorted(by : { $0.symbol < $1.symbol })
                
                //update unit values
                let currencyGroup = self.unitGroups.first!
                let units = currencyGroup.units.array as! [Unit]
                for unit in units
                {
                    for rate in rates
                    {
                        if unit.symbol == rate.symbol
                        {
                            unit.ratio = rate.ratio
                            break
                        }
                    }
                    continue
                }
                
                //update currency fetch date
                self.setting!.lastCurrency = Date()
                DM.saveContext()
                
                self.convertView.refreshLbl.isHidden    = false
                self.unitList.isHidden                  = false
                self.convertView.refreshLbl.text        = "#pullAddUnit".local
                
                self.unitList.reloadData()
            }
            
            }.resume()
        
    }
    
    func saveToPhotos()
    {
        //case
        switch PHPhotoLibrary.authorizationStatus()
        {
        case .authorized :
            let documentURL = try! FileManager().url(for : .documentDirectory, in : .userDomainMask,
                                                     appropriateFor : nil, create : true)
            let fileName    = "[zero] share.png"
            var message     = ""
            
            //fetch destination URL
            let fileURL     = documentURL.appendingPathComponent(fileName)
            let image       = UIImage(contentsOfFile : fileURL.path)
            
            PHPhotoLibrary.shared().performChanges({ PHAssetChangeRequest.creationRequestForAsset(from : image!) },
            completionHandler : { success, error in
                                                    
                if success
                {
                    message = "#imageSaveSuccess".local
                }
                else if let _error = error
                {
                    message = "\("#imageSaveError".local) : '\(_error.localizedDescription)'"
                }
                else
                {
                    message = "#imageSaveFailed".local
                }
                
                //alert
                let alert = UIAlertController(title : nil, message : message, preferredStyle : .alert)
                alert.addAction(UIAlertAction(title : "#OK".local, style : .destructive) { action in
                    self.equationField.becomeFirstResponder()
                })
                
                //show alert
                rootVC.present(alert, animated : true, completion : nil)
                
            })
            
        case .denied, .notDetermined :
            PHPhotoLibrary.requestAuthorization({(status) in
                switch status
                {
                case .authorized :
                    self.saveToPhotos()
                    
                case .denied :
                    let alert = UIAlertController(title     : "#photoLackPermission".local,
                                                  message   : "#noPermissionCaption".local, preferredStyle : .alert)
                    alert.addAction(UIAlertAction(title : "#OK".local, style : .destructive) { action in
                        self.equationField.becomeFirstResponder()
                    })
                    
                    rootVC.present(alert, animated : true, completion : nil)
                    
                default : break
                }
            })
            
        default :
            let alert = UIAlertController(title : nil, message : "#photoAccessRestricted".local, preferredStyle : .alert)
            alert.addAction(UIAlertAction(title : "#OK".local, style : .destructive) { action in
                self.equationField.becomeFirstResponder()
                
            })
            rootVC.present(alert, animated : true, completion : nil)
            
        }

    }
    
    func prepareSoundPlay()
    {
        let soundFileURL = URL(fileURLWithPath : Bundle.main.path(forResource : "buttonPress", ofType : "mp3")!)
        
        self.audioPlayer = try! AVAudioPlayer(contentsOf : soundFileURL)
        self.audioPlayer.prepareToPlay()
    }
    
    func delete(equations : inout [Equation], targetList : inout ListView?, targetPaths : inout [IndexPath], state : SelectionState)
    {
        for equation in equations
        {
            //detach from holdingValue
            if let holdingValue = DM.fetchValue(withEquationUID : equation.uid)
            {
                holdingValue.isEquation = false
            }
            
            //case
            if state == .EquationDeleteConfirm
            {
                //detach members
                for value in equation.fetchValues()
                {
                    value.belongTo = ""
                    equation.remove(value : value)
                }
                for operation in equation.fetchOperations()
                {
                    equation.remove(operation : operation)
                }
            }
            else
            {
                //delete members
                for value in equation.fetchValues()
                {
                    if let holdingGroup = value.group
                    {
                        if holdingGroup.fetchValues().contains(value)
                        {
                            holdingGroup.remove(value : value)
                        }
                    }
                    if self.values.contains(value)
                    {
                        self.values.remove(at : self.values.index(of : value)!)
                    }
                    if self.recentValues.contains(value)
                    {
                        self.recentValues.remove(at : self.recentValues.index(of : value)!)
                    }
                    equation.remove(value : value)
                    DM.managedObjectContext.delete(value)
                }
                for operation in equation.fetchOperations()
                {
                    equation.remove(operation : operation)
                }
            }
            
            //set targetList
            targetList = self.manageDisplayed ? self.manageList : self.controlState == .Group ?
                                                self.groupEntityList : self.recentList
            
            //set targetPath
            for (sectionIndex, section) in self.equationSections.enumerated()
            {
                for (equationIndex, _equation) in section.enumerated()
                {
                    if _equation == equation
                    {
                        targetPaths.append(IndexPath(row : equationIndex, section : sectionIndex))
                    }
                }
            }
            
            //validate
            if self.currentEquation == equation
            {
                //more than one left
                if self.currentEquations.count != 1
                {
                    let currentIndex = self.currentEquations.index(of : equation)
                    
                    //fetch next equation
                    if self.currentEquations.indices.contains(currentIndex! + 1)
                    {
                        self.currentEquation = self.currentEquations[currentIndex! + 1]
                    }
                    //fetch previous equation
                    else
                    {
                        self.currentEquation = self.currentEquations[currentIndex! - 1]
                    }
                }
                //last remaining
                else
                {
                    //fetch new equation
                    let newEquation = DM.fetchInventoryEquation()
                    
                    if newEquation == equation
                    {
                        self.currentEquation = DM.createEquation(withName : "")
                    }
                    else
                    {
                        self.currentEquation = newEquation
                    }
                    
                    //add to arrays
                    self.currentEquations.append(self.currentEquation!)
                    if !self.equations.contains(self.currentEquation!)
                    {
                        self.equations.append(self.currentEquation!)
                    }
                    if !self.recentEquations.contains(self.currentEquation!)
                    {
                        self.recentEquations.append(self.currentEquation!)
                    }
                }
            }
            
            //remove from arrays
            if let holdingGroup = equation.group
            {
                if holdingGroup.fetchEquations().contains(equation)
                {
                    holdingGroup.remove(equation : equation)
                }
            }
            if self.currentEquations.contains(equation)
            {
                self.currentEquations.remove(at : self.currentEquations.index(of : equation)!)
            }
            if self.equations.contains(equation)
            {
                self.equations.remove(at : self.equations.index(of : equation)!)
            }
            if self.recentEquations.contains(equation)
            {
                self.recentEquations.remove(at : self.recentEquations.index(of : equation)!)
            }
        }
        
    }
    
    func delete(values : inout [Value], targetList : inout ListView?, targetPaths : inout [IndexPath], state : SelectionState)
    {
        for value in values
        {
            //check if value belongs to equation
            if let equation = DM.fetchEquation(forUID : value.belongTo)
            {
                let valueIndex = equation.fetchValues().index(of : value)!
                
                //previous operation exists
                if equation.fetchOperations().indices.contains(valueIndex - 1)
                {
                    //remove operation
                    let operationBeforeValue = equation.fetchOperations()[valueIndex - 1]
                    equation.remove(operation : operationBeforeValue)
                }
                else if equation.fetchOperations().indices.contains(valueIndex)
                {
                    //remove operation
                    let operationAfterValue = equation.fetchOperations()[valueIndex]
                    equation.remove(operation : operationAfterValue)
                }
                
                //remove value
                equation.remove(value : value)
                
                //validate
                if equation.valueCount() == 0
                {
                    let newValue = DM.createValue(forEquation : equation)
                    equation.append(value : newValue)
                    
                    //add to arrays
                    if !self.values.contains(newValue)
                    {
                        self.values.append(newValue)
                    }
                }
                if equation == self.currentEquation
                {
                    equation.lastValue()?.highlight()
                    self.operationView.reloadData()
                }
                
                //update equation
                self.calculate(equation : equation)
            }
            
            //set targetList
            targetList = self.manageDisplayed ? self.manageList : self.controlState == .Group ?
                                                self.groupEntityList : self.recentList
            
            //set targetPath
            for (sectionIndex, section) in self.valueSections.enumerated()
            {
                for (valueIndex, _value) in section.enumerated()
                {
                    if _value == value
                    {
                        targetPaths.append(IndexPath(row : valueIndex, section : sectionIndex))
                    }
                }
            }
            
            //remove from arrays
            if let holdingGroup = value.group
            {
                if holdingGroup.fetchValues().contains(value)
                {
                    holdingGroup.remove(value : value)
                }
            }
            if self.recentValues.contains(value)
            {
                self.recentValues.remove(at : self.recentValues.index(of : value)!)
            }
            if self.values.contains(value)
            {
                self.values.remove(at : self.values.index(of : value)!)
            }
        }
    }
    
    func delete(tags : inout [Tag], targetList : inout ListView?, targetPaths : inout [IndexPath], state : SelectionState)
    {
        for tag in tags
        {
            //set targetList
            targetList = self.manageDisplayed ? self.manageList : self.controlState == .Group ?
                                                self.groupEntityList : self.tagList
            
            //set targetPath
            for (sectionIndex, section) in self.tagSections.enumerated()
            {
                for (tagIndex, _tag) in section.enumerated()
                {
                    if _tag == tag
                    {
                        targetPaths.append(IndexPath(row : tagIndex, section : sectionIndex))
                    }
                }
            }
            
            //remove from array
            if self.tags.contains(tag)
            {
                self.tags.remove(at : self.tags.index(of : tag)!)
            }
        }
    }
    
    
    //MARK: - Button Delegate

    
    func cancel(state : CancelState)
    {
        switch state
        {
        /* root */
        
        case .CreateEntity : self.refreshControl()
            
        case .Reset :
            self.refreshControl()
        
        case .ResetConfirm :
            self.control.layout(cancel : .Reset)
            
            self.selectionView.reset()
            self.equationField.inputView = self.selectionView
            self.equationField.reloadInputViews()
        
        case .Delete :
            if self.manageDisplayed
            {
                if self.selectedState != .Group
                {
                    switch self.selectedState
                    {
                    case .Equation  : self.selectedEquation = nil
                    case .Value     : self.selectedValue = nil
                    case .Tag       : self.selectedTag = nil
                    default         : break
                    }
                }
                
                self.equationField.resignFirstResponder()
            }
            else
            {
                if self.selectedState == .Group
                {
                    self.control.layout(cancel : .GroupEdit)
                    self.selectionView.groupEdit()
                    self.equationField.inputView = self.selectionView
                    self.equationField.reloadInputViews()
                }
                else
                {
                    switch self.selectedState
                    {
                    case .Equation  : self.selectedEquation = nil
                    case .Value     : self.selectedValue = nil
                    case .Tag       :
                        self.selectedTag = nil
                        self.refreshControl()
                        self.recentView.showTags()
                        
                        return
                        
                    default         : break
                    }
                    
                    self.refreshControl()
                }
            }
        
        /* group */
        
        case .GroupEdit, .GroupCreateEntity :
            if self.manageDisplayed
            {
                self.equationField.resignFirstResponder()
            }
            else
            {
                self.refreshControl()
                self.groupView.updateLayout(withAnimation : false)
            }
        
        case .GroupAction :
            self.control.layout(cancel : .GroupEdit)
            self.selectionView.groupEdit()
            
            //update state
            switch self.highlightedState
            {
            case .Equation  : self.operationState = .NameTyping
            case .Value     : self.operationState = .ValueTyping
            case .Operation : self.operationState = .OnOperation
            }
            self.fieldState = .None
        
            //reload
            self.equationField.inputView = self.selectionView
            self.equationField.reloadInputViews()
        
        /* equation */
        
        case .Equation :
            if self.manageDisplayed
            {
                //remove info
                self.infoView.remove()
                
                if self.viewState == .ManageSearch
                {
                    self.manageVC!.searchList()
                }
                else
                {
                    //de-register
                    self.selectedEquation = nil
                    
                    //adjust segment rect
                    let segmentPos              = CGPoint(x : 0, y : topBarHeight)
                    let segmentSize             = CGSize(width : refWidth, height : cellHeight)
                    self.entitySegment.frame    = CGRect(origin : segmentPos, size : segmentSize)
                    
                    self.equationField.resignFirstResponder()
                }
                
                //reload
                self.entityState = .EntityEquation
                collection.configureManageSections()
                
                //add back segment
                self.entitySegment.activateLayout()
                self.manageVC!.view.addSubview(self.entitySegment)
            }
            else
            {
                if self.viewState == .RootSearch
                {
                    //de-register
                    self.selectedEquation = nil
                    
                    self.infoView.remove()
                    self.blurView.isHidden = false
                    
                    //activate valueInput
                    self.valueField.inputView = nil
                    self.valueField.layoutSearch()
                    
                    self.control.layout(field : .Search)
                    
                    self.valueField.becomeFirstResponder()
                    self.valueField.reloadInputViews()
                    
                    //reload
                    self.entityState = .EntityEquation
                    collection.configureManageSections()
                    
                    //adjust segment
                    self.entitySegment.activateLayout()
                    self.entitySegment.frame = CGRect(origin : CGPoint(x : 0, y : statusBarHeight),
                                                      size : self.entitySegment.frame.size)
                    self.blurView.addSubview(self.entitySegment)
                    
                    return
                }
                else
                {
                    if self.selectedEquation == self.currentEquation
                    {
                        self.selectedEquation!.highlight()
                    }
                    if let selectedEquation = self.selectedEquation
                    {
                        if self.searchedEquations.contains(selectedEquation)
                        {
                            self.selectedEquation = nil
                        }
                    }
                    
                    //release scroll
                    self.groupList.isScrollEnabled = true
                    self.tagList.isScrollEnabled = true
                
                    self.refreshControl()
                    
                    if self.controlState == .Recent
                    {
                        if self.recentState == .RecentTag
                        {
                            self.recentView.showTags()
                        }
                        else
                        {
                            self.recentView.removeTags()
                            self.recentList.reloadData()
                        }
                    }
                    else if self.controlState == .Group
                    {
                        collection.configureGroupSections()
                        collection.configureGroupEntitySections()
                        self.groupView.updateLayout(withAnimation : false)
                    }
                    
                    self.infoView.remove()
                }
            }
            
            //de-register
            self.selectedEquation = nil
            self.selectedState = .None
            
            self.equationView.activateEquation()
            self.operationView.reloadData()
            self.searchView.reloadData()
            
        case .EquationAction :
            SM.adjustSelection(withState : .Equation)
            
            self.control.layout(cancel : .Equation)
            self.selectionView.equation(selectFrom : self.selectFrom)
            self.infoView.show()
            
            //update state
            switch self.highlightedState
            {
            case .Equation  : self.operationState = .NameTyping
            case .Value     : self.operationState = .ValueTyping
            case .Operation : self.operationState = .OnOperation
            }
            self.fieldState = .None
            
            //reload
            self.equationField.inputView = self.selectionView
            self.equationField.reloadInputViews()
        
            //validate
            if self.searchedEquations.contains(self.selectedEquation!)
            {
                self.searchView.reloadData()
            }
        
        case .EquationDeleteConfirm :
            self.control.layout(cancel : .Delete)
            self.selectionView.delete(state : .EntityEquation)
            self.equationField.inputView = self.selectionView
            self.equationField.reloadInputViews()
            
        case .SearchedEquation :
            if let selectedSearchedEquation = self.selectedSearchedEquation
            {
                if self.searchedEquations.contains(selectedSearchedEquation)
                {
                    self.selectedSearchedEquation = nil
                }
            }
            
            //release scroll
            self.groupList.isScrollEnabled = true
            self.tagList.isScrollEnabled = true
            
            self.refreshControl()
            
            if self.controlState == .Recent
            {
                if self.recentState == .RecentTag
                {
                    self.recentView.showTags()
                }
                else
                {
                    self.recentView.removeTags()
                    self.recentList.reloadData()
                }
            }
            else if self.controlState == .Group
            {
                collection.configureGroupSections()
                collection.configureGroupEntitySections()
                self.groupView.updateLayout(withAnimation : false)
            }
            
            self.infoView.remove()
            
            //de-register
            self.selectedSearchedEquation = nil
            self.selectedState = .None
            
            self.equationView.activateEquation()
            self.operationView.reloadData()
            self.searchView.reloadData()
            
        case .SearchedEquationAction :
            SM.adjustSelection(withState : .Equation)
            
            self.control.layout(cancel : .SearchedEquation)
            self.selectionView.equation(selectFrom : self.selectFrom)
            self.infoView.show()
            
            //update state
            switch self.highlightedState
            {
            case .Equation  : self.operationState = .NameTyping
            case .Value     : self.operationState = .ValueTyping
            case .Operation : self.operationState = .OnOperation
            }
            self.fieldState = .None
            
            //reload
            self.equationField.inputView = self.selectionView
            self.equationField.reloadInputViews()
            
            //validate
            if self.searchedEquations.contains(self.selectedSearchedEquation!)
            {
                self.searchView.reloadData()
            }

        /* value */
        
        case .Value :
            if self.manageDisplayed
            {
                //remove info
                self.infoView.remove()
                
                if self.viewState == .ManageSearch
                {
                    self.manageVC!.searchList()
                }
                else
                {
                    //de-register
                    self.selectedValue = nil
                    
                    //adjust segment rect
                    let segmentPos              = CGPoint(x : 0, y : topBarHeight)
                    let segmentSize             = CGSize(width : refWidth, height : cellHeight) //barHeight
                    self.entitySegment.frame    = CGRect(origin : segmentPos, size : segmentSize)
                    
                    self.equationField.resignFirstResponder()
                }
                
                //reload
                self.entityState = .EntityValue
                collection.configureManageSections()
                
                //add back segment
                self.entitySegment.activateLayout()
                self.manageVC!.view.addSubview(self.entitySegment)
            }
            else
            {
                if self.viewState == .RootSearch
                {
                    //de-register
                    self.selectedValue = nil
                    
                    self.infoView.remove()
                    self.blurView.isHidden = false
                    
                    //activate valueInput
                    self.valueField.inputView = nil
                    self.valueField.layoutSearch()
                    
                    self.control.layout(field : .Search)
                    
                    self.valueField.becomeFirstResponder()
                    self.valueField.reloadInputViews()
                    
                    //reload
                    self.entityState = .EntityValue
                    collection.configureManageSections()
                    
                    //adjust segment
                    self.entitySegment.activateLayout()
                    self.entitySegment.frame = CGRect(origin : CGPoint(x : 0, y : statusBarHeight),
                                                      size : self.entitySegment.frame.size)
                    self.blurView.addSubview(self.entitySegment)
                    
                    return
                }
                else
                {
                    if self.currentEquation!.fetchValues().contains(self.selectedValue!)
                    {
                        self.selectedValue?.highlight()
                    }
                    if let selectedValue = self.selectedValue
                    {
                        if self.searchedValues.contains(selectedValue)
                        {
                            self.selectedValue = nil
                        }
                    }
                    
                    //release scroll
                    self.groupList.isScrollEnabled = true
                    self.tagList.isScrollEnabled = true
                    
                    self.refreshControl()
                    
                    if self.controlState == .Recent
                    {
                        if self.recentState == .RecentTag
                        {
                            self.recentView.showTags()
                        }
                        else
                        {
                            self.recentView.removeTags()
                            self.recentList.reloadData()
                        }
                    }
                    else if self.controlState == .Group
                    {
                        collection.configureGroupSections()
                        collection.configureGroupEntitySections()
                        self.groupView.updateLayout(withAnimation : false)
                    }
                    
                    self.infoView.remove()
                }
            }
            
            //de-register
            self.selectedValue = nil
            self.selectedState = .None
            
            self.equationView.activateEquation()
            self.operationView.reloadData()
            self.searchView.reloadData()
        
        case .ValueAction :
            SM.adjustSelection(withState : .Value)
            
            if self.operationState == .WillSwitch
            {
                self.operationState = self.controlState == .Calculator ? .ValueTyping : .NameTyping
            }
            
            self.control.layout(cancel : .Value)
            
            self.selectionView.value(selectFrom : self.selectFrom)
            self.infoView.show()
            
            self.equationField.inputView = self.selectionView
            self.equationField.reloadInputViews()
            
            //update state
            switch self.highlightedState
            {
            case .Equation  : self.operationState = .NameTyping
            case .Value     : self.operationState = .ValueTyping
            case .Operation : self.operationState = .OnOperation
            }
            self.fieldState = .None
        
            //validate
            if self.searchedValues.contains(self.selectedValue!)
            {
                self.searchView.reloadData()
            }
            
        case .ValueOption :
            self.valueField.inputView = nil
            self.valueField.layoutEntityInput()
            self.control.layout(field : .EditValue)
            self.valueField.becomeFirstResponder()
            self.valueField.reloadInputViews()
            
        case .SearchedValue :
            if let selectedSearchedValue = self.selectedSearchedValue
            {
                if self.searchedValues.contains(selectedSearchedValue)
                {
                    self.selectedSearchedValue = nil
                }
            }
            
            //release scroll
            self.groupList.isScrollEnabled = true
            self.tagList.isScrollEnabled = true
            
            self.refreshControl()
            
            if self.controlState == .Recent
            {
                if self.recentState == .RecentTag
                {
                    self.recentView.showTags()
                }
                else
                {
                    self.recentView.removeTags()
                    self.recentList.reloadData()
                }
            }
            else if self.controlState == .Group
            {
                collection.configureGroupSections()
                collection.configureGroupEntitySections()
                self.groupView.updateLayout(withAnimation : false)
            }
            
            self.infoView.remove()
            
            //de-register
            self.selectedSearchedValue = nil
            self.selectedState = .None
            
            self.equationView.activateEquation()
            self.operationView.reloadData()
            self.searchView.reloadData()
            
        case .SearchedValueAction :
            SM.adjustSelection(withState : .Value)
            
            self.control.layout(cancel : .SearchedValue)
            
            self.selectionView.value(selectFrom : self.selectFrom)
            self.infoView.show()
            
            self.equationField.inputView = self.selectionView
            self.equationField.reloadInputViews()
            
            //update state
            switch self.highlightedState
            {
            case .Equation  : self.operationState = .NameTyping
            case .Value     : self.operationState = .ValueTyping
            case .Operation : self.operationState = .OnOperation
            }
            self.fieldState = .None
            
            //validate
            if self.searchedValues.contains(self.selectedSearchedValue!)
            {
                self.searchView.reloadData()
            }
        
        /* tag */
        
        case .Tag :
            if self.manageDisplayed
            {
                //remove info
                self.infoView.remove()
                
                if self.viewState == .ManageSearch
                {
                    self.manageVC!.searchList()
                }
                else
                {
                    //de-register
                    self.selectedTag = nil
                    
                    //adjust segment rect
                    let segmentPos              = CGPoint(x : 0, y : topBarHeight)
                    let segmentSize             = CGSize(width : refWidth, height : cellHeight)
                    self.entitySegment.frame    = CGRect(origin : segmentPos, size : segmentSize)
                    
                    self.equationField.resignFirstResponder()
                }
                
                //reload
                self.entityState = .EntityTag
                collection.configureManageSections()
                
                //add back segment
                self.entitySegment.activateLayout()
                self.manageVC!.view.addSubview(self.entitySegment)
            }
            else
            {
                if self.viewState == .RootSearch
                {
                    //de-register
                    self.selectedTag = nil
                    
                    self.infoView.remove()
                    self.blurView.isHidden = false
                    
                    //activate valueInput
                    self.valueField.inputView = nil
                    self.valueField.layoutSearch()
                    
                    self.control.layout(field : .Search)
                    
                    self.valueField.becomeFirstResponder()
                    self.valueField.reloadInputViews()
                    
                    //reload
                    self.entityState = .EntityTag
                    collection.configureManageSections()
                    
                    //adjust segment
                    self.entitySegment.activateLayout()
                    self.entitySegment.frame = CGRect(origin : CGPoint(x : 0, y : statusBarHeight),
                                                      size : self.entitySegment.frame.size)
                    self.blurView.addSubview(self.entitySegment)
                }
                else
                {
                    self.operationView.reloadData()
                    self.refreshControl()
                    
                    if self.controlState == .Recent
                    {
                        if self.recentState == .RecentTag
                        {
                            self.recentView.showTags()
                        }
                        else
                        {
                            self.recentView.removeTags()
                            self.recentList.reloadData()
                        }
                    }
                    else if self.controlState == .Group
                    {
                        self.groupView.updateLayout(withAnimation : false)
                    }
                
                    self.infoView.remove()
                }
            }
            
            //de-register
            self.selectedTag = nil
        
        case .TagAction :
            SM.adjustSelection(withState : .Tag)
            
            self.control.layout(cancel : .Tag)
            
            self.selectionView.listTag()
            self.infoView.show()
            
            self.equationField.inputView = self.selectionView
            self.equationField.reloadInputViews()
            
            //update state
            switch self.highlightedState
            {
            case .Equation  : self.operationState = .NameTyping
            case .Value     : self.operationState = .ValueTyping
            case .Operation : self.operationState = .OnOperation
            }
            self.fieldState = .None
        
        /* operation */
        
        case .Operation :
            self.selectedOperation?.highlight()
            self.selectedState = .None
            
            self.operationView.reloadData()
            self.refreshControl()
            
            return
            
        /* manage */
        
        case .ManageSearch :
            //display
            self.manageVC!.topBar.isHidden      = false
            self.manageVC!.bottomBar.isHidden   = false
            self.entitySegment.isHidden         = false
            self.operationState                 = .ValueTyping
            self.fieldState                     = .None
            self.viewState                      = .Manage
            
            //prepare rects
            let segmentPos                      = CGPoint(x : 0, y : topBarHeight)
            let segmentSize                     = CGSize(width : refWidth, height : cellHeight)
            
            let listHeight                      = isIphoneX ?
                                                  refHeight - (topBarHeight + cellHeight + bottomBarHeight + homeBuffer) :
                                                  refHeight - (topBarHeight + cellHeight + bottomBarHeight)
            let listPos                         = CGPoint(x : 0, y : topBarHeight + cellHeight)
            let listSize                        = CGSize(width : refWidth, height : listHeight)
            
            //set rects
            self.entitySegment.frame            = CGRect(origin : segmentPos, size : segmentSize)
            self.manageList.frame               = CGRect(origin : listPos, size : listSize)
            
            //reload
            self.entitySegment.activateLayout()
            collection.configureManageSections()
        
            self.valueField.text = ""
            self.valueField.resignFirstResponder()
            self.valueField.removeFromSuperview()
        
        case .ManageCreateEntity :
            
            //animate
            UIView.animate(withDuration : 0.15, delay : 0, options : .curveEaseIn, animations : {
                self.manageVC!.curtain.alpha = 0
                
            }) { (finished) in
                if finished
                {
                    self.manageVC!.curtain.isHidden = true
                    self.manageVC!.curtain.removeFromSuperview()
                    
                    //disable interaction
                    self.manageVC!.topBar.isUserInteractionEnabled  = true
                    self.entitySegment.isUserInteractionEnabled     = true
                    self.manageList.isUserInteractionEnabled        = true
                    
                    self.blurView.cancel()
                }
            }
            
            UIView.animate(withDuration : 0.3, delay : 0, options : .transitionCrossDissolve, animations : {
                self.selectionView.alpha = 0
                self.control.alpha = 0
                self.equationField.resignFirstResponder()
                
            }, completion : { (finished) in
                if finished
                {
                    UIView.animate(withDuration : 0.2, animations : {
                        self.selectionView.alpha = 1
                        self.control.alpha = 1
                    })
                }
            })
            
        }
    }
    
    func control(state : ControlState)
    {
        switch state
        {
        //firstLine
        case .Calculator :
            self.controlState = .Calculator
            self.refreshControl()
            return

        case .Keyboard :
            self.controlState = .Keyboard
            self.refreshControl()
            return
        
        case .Recent :
            self.controlState = state
            self.refreshControl()
            
            //prepare date format
            self.dateFormatter.dateFormat = "YY.MM.dd"
            
            //fetch recent
            self.fetchRecent()
            collection.configureRecentSections()
            
            //sort with filters
            if self.filters.filter({ $0.selected == true }).count != 0
            {
                self.applyFilters()
            }
            
            if self.recentState == .RecentTag
            {
                self.recentView.showTags()
            }
            
            return
        
        case .Group :
            self.controlState = state
            self.refreshControl()
            
            //validate layout
            collection.configureGroupSections()
            collection.configureGroupEntitySections()
            
            //sort with filters
            if self.filters.filter({ $0.selected == true }).count != 0
            {
                self.applyFilters()
            }
            
            self.groupView.updateLayout(withAnimation : false)
        
            return
        
        case .Convert :
            self.controlState = state
            self.convertView.adjust(height : isIphoneX ? (btnLength * 4) + bottomBuffer : btnLength * 4)
            
            self.refreshControl()
            
            if self.selectedUnitGroup?.name == "#currency".local
            {
                self.checkNetworkStatus()
            }
            
            //set scroll
            self.unitGroupList.isScrollEnabled = self.setting!.bigFont.boolValue ? true : false
            
            //reload model
            self.unitGroupList.reloadData()
            self.unitList.reloadData()
        
            return
        
        case .Setting :
            rootVC.displaySettings()
        
        //secondLine
        case .PreviousEquation  : self.navigateEquation(withControlState : .PreviousEquation); return
        case .PreviousItem      : self.navigateItem(withControlState : .PreviousItem); return
        case .Select            : self.selectItem(); return
        case .NextItem          : self.navigateItem(withControlState : .NextItem); return
        case .NextEquation      : self.navigateEquation(withControlState : .NextEquation); return
        }
        
        //remove displayed blurView
        self.blurView.removeFromSuperview()
        
        //reload
        self.equationField.reloadInputViews()
        self.searchView.reloadData()
    }
    
    func calculate(icon : Icon)
    {
        if self.setting!.playSound == true
        {
            self.audioPlayer.currentTime = 0
            self.audioPlayer.play()
        }
        
        switch icon
        {
        case .Backspace :
            if self.valueField.isFirstResponder
            {
                if self.entityValueStr != "0"
                {
                    let nonCommaStr = self.validateByRemovingComma(fromValueStr : self.entityValueStr)
                    let updatedStr = String(nonCommaStr.dropLast())
                    
                    if updatedStr == ""
                    {
                        self.entityValueStr = "0"
                    }
                    else
                    {
                        self.entityValueStr = self.validateByInsertingComma(toValueStr : updatedStr)
                    }
                    
                    //activate editView
                    self.editView.show()
                }
                
                return
            }
            
            //validate (equationValue check)
            if let value = self.highlightedValue
            {
                //validate (equationValue check)
                if value.isEquation == true
                {
                    //reload
                    SM.adjustSelection(withState : .ValueEquationCheck)
                    self.selectFrom = .Operation
                    
                    value.select()
                    self.control.layout(cancel : .Value)
                    self.selectionView.valueEquationCheck()
                    self.equationField.inputView = self.selectionView
                    self.equationField.reloadInputViews()
                    
                    return
                }
            }
            
            self.backspace()
        
        case .Reset :
            if self.valueField.isFirstResponder
            {
                self.entityValueStr = "0"
                
                //activate editView
                self.editView.show()
                
                return
            }
            
            //case
            if self.setting!.resetAutoSave == false
            {
                //layout manual-save
                SM.adjustSelection(withState : .Reset)
                self.control.layout(cancel : .Reset)
                
                self.selectionView.reset()
                self.equationField.inputView = self.selectionView
                self.equationField.reloadInputViews()
                
                return
            }
            
            //auto-save
            self.saveReset()
        
        case .Percentage :
            if self.valueField.isFirstResponder
            {
                let value = NSDecimalNumber(decimal : self.numberFormatter.number(from : self.entityValueStr)!.decimalValue)
                let updatedValue = value.multiplying(by : 0.01)
                
                self.entityValueStr = self.numberFormatter.string(from : updatedValue)!
                
                //activate editView
                self.editView.show()

                return
            }
            
            if self.highlightedState == .Value
            {
                //fetch on-going value
                let value = self.highlightedValue!
                
                //validate (equationValue check)
                if value.isEquation == true
                {
                    //reload
                    SM.adjustSelection(withState : .ValueEquationCheck)
                    self.selectFrom = .Operation
                    
                    value.select()
                    self.control.layout(cancel : .Value)
                    self.selectionView.valueEquationCheck()
                    self.equationField.inputView = self.selectionView
                    self.equationField.reloadInputViews()
                    
                    return
                }
                
                value.value         = value.value.multiplying(by : 0.01)
                value.valueStr      = self.numberFormatter.string(from : value.value)!
                
                //update modifiedDate
                value.modifiedDate  = Date()
                
                //update search
                self.search()
                
                //calculate value
                self.calculate(equation : self.currentEquation!)
            }
            
            return
            
        case .PlusMinus :
            if self.valueField.isFirstResponder
            {
                //is negative
                if self.entityValueStr.contains("-")
                {
                    if self.entityValueStr.count == 1 && self.entityValueStr == "-"
                    {
                        self.entityValueStr = "0"
                    }
                    else
                    {
                        let positiveValueStr = self.entityValueStr.replacingOccurrences(of: "-", with: "")
                        self.entityValueStr = positiveValueStr
                    }
                }
                //is not negative but zero
                else if self.entityValueStr.count == 1 && self.entityValueStr == "0"
                {
                    let negativeStr = "-"
                    self.entityValueStr = negativeStr
                }
                //is not negative
                else
                {
                    let negativeValueStr = "-" + self.entityValueStr
                    self.entityValueStr = negativeValueStr
                }
                
                //activate editView
                self.editView.show()
                
                return
            }
            
            var value : Value?
            
            //onOperation (create new value)
            if operationState == .OnOperation
            {
                //fetch targetIndex
                let targetIndex = self.currentEquation!.fetchIndex(ofOperation : self.highlightedOperation!)
                
                //create new operation & value
                value = DM.createValue(forEquation : self.currentEquation!)
                self.values.append(value!)
                
                //set model
                value!.valueStr     = "-"
                value!.value        = NSDecimalNumber(decimal : self.numberFormatter.number(from : "-0")!.decimalValue)
                
                //update modifiedDate
                value!.modifiedDate = Date()
                
                //validate range
                if self.currentEquation!.fetchValues().indices.contains(targetIndex + 1)
                {
                    let newOperation = DM.createOperation(forIcon : .Add)
                    
                    //add operation, value within
                    self.currentEquation!.insert(value : value!, atIndex : targetIndex + 1)
                    self.currentEquation!.insert(operation : newOperation, atIndex : targetIndex)
                }
                //append
                else
                {
                    self.currentEquation!.append(value : value!)
                }
            }
            //typing (continue typing value)
            else if self.operationState == .ValueTyping || self.operationState == .NameTyping
            {
                //fetch on-going value
                value = self.highlightedValue!
                
                //validate (equationValue check)
                if value!.isEquation == true
                {
                    //reload
                    SM.adjustSelection(withState : .ValueEquationCheck)
                    self.selectFrom = .Operation
                    
                    value!.select()
                    self.control.layout(cancel : .Value)
                    self.selectionView.valueEquationCheck()
                    self.equationField.inputView = self.selectionView
                    self.equationField.reloadInputViews()
                    
                    return
                }
                
                //is negative
                if value!.valueStr.contains("-")
                {
                    if value!.valueStr.count == 1 && value!.valueStr == "-"
                    {
                        value!.valueStr = "0"
                        value!.value    = NSDecimalNumber(decimal : self.numberFormatter.number(from :
                                                                    value!.valueStr)!.decimalValue)
                    }
                    else
                    {
                        let positiveValueStr = value!.valueStr.replacingOccurrences(of: "-", with: "")
                        
                        value!.valueStr = positiveValueStr
                        value!.value    = NSDecimalNumber(decimal : self.numberFormatter.number(from :
                                                                    value!.valueStr)!.decimalValue)
                    }
                }
                //is not negative but zero
                else if value!.valueStr.count == 1 && value!.valueStr == "0"
                {
                    let negativeStr     = "-"
                    
                    value!.valueStr     = negativeStr
                    value!.value        = NSDecimalNumber(decimal : self.numberFormatter.number(from : "-0")!.decimalValue)
                }
                //is not negative
                else
                {
                    let negativeValueStr = "-" + value!.valueStr
                    
                    value!.valueStr     = negativeValueStr
                    value!.value        = NSDecimalNumber(decimal : self.numberFormatter.number(from :
                                                                    value!.valueStr)!.decimalValue)
                }
                
                //update modifiedDate
                value!.modifiedDate     = Date()
            }
            
            //update state
            self.operationState = .ValueTyping
            self.highlightedValue = value!
            
            //highlight value
            value!.highlight()
            
            //update search
            self.search()
            
            //calculate value
            self.calculate(equation : self.currentEquation!)
            
        case .Dot, .DoubleZero, .Zero, .One, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine :
            if self.valueField.isFirstResponder
            {
                //validate (empty before input)
                if self.entityValueStr.count == 1 && self.entityValueStr == "0"
                {
                    let numbers : [Icon] = [.Zero, .One, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine]
                    
                    if numbers.contains(icon)
                    {
                        self.entityValueStr = ""
                    }
                }
                
                //limit input
                let simulatedStr = self.entityValueStr + icon.rawValue
                if self.entityValueStr.count >= 19 || simulatedStr.count > 19
                {
                    return
                }
                
                //validate (prevent double-dot)
                if self.entityValueStr.contains(".") && icon.rawValue == "."
                {
                    return
                }
                
                //validate
                var noCommaValueStr = self.validateByRemovingComma(fromValueStr : self.entityValueStr)
                
                //re-validate
                if noCommaValueStr == "-" && icon.rawValue == "."
                {
                    noCommaValueStr += "0"
                }
                
                if (noCommaValueStr == "-0" || noCommaValueStr == "0") && icon.rawValue != "."
                {
                    noCommaValueStr = noCommaValueStr.replacingOccurrences(of : "0", with: "")
                }
                
                let valueStr = noCommaValueStr + icon.rawValue
                let validatedStr = self.validateByInsertingComma(toValueStr : valueStr)
                
                self.entityValueStr = validatedStr
                
                //activate editView
                self.editView.show()
                
                return
            }
            
            var value : Value?
            
            //onOperation (create new value)
            if self.operationState == .OnOperation
            {
                //validate (prevent double-zero)
                if icon == .DoubleZero
                {
                    return
                }
                
                //fetch targetIndex
                let targetIndex = self.currentEquation!.fetchIndex(ofOperation : self.highlightedOperation!)
                
                //create new operation & value
                value = DM.createValue(forEquation : self.currentEquation!)
                self.values.append(value!)
                
                //set model
                if icon == .Dot
                {
                    value!.valueStr = "0."
                }
                else
                {
                    value!.valueStr = icon.rawValue
                }
                
                value!.value = NSDecimalNumber(decimal : self.numberFormatter.number(from : value!.valueStr)!.decimalValue)
                
                //validate range
                if self.currentEquation!.fetchValues().indices.contains(targetIndex + 1)
                {
                    let newOperation = DM.createOperation(forIcon : .Add)
                    
                    //add operation, value within
                    self.currentEquation!.insert(value : value!, atIndex : targetIndex + 1)
                    self.currentEquation!.insert(operation : newOperation, atIndex : targetIndex)
                }
                //append
                else
                {
                    self.currentEquation!.append(value : value!)
                }
            }
            //typing (continue typing value)
            else if self.operationState == .ValueTyping || self.operationState == .NameTyping
            {
                //fetch highlighted value
                value = self.highlightedValue!
                
                //validate (equationValue check)
                if value!.isEquation == true
                {
                    //reload
                    SM.adjustSelection(withState : .ValueEquationCheck)
                    self.selectFrom = .Operation
                    
                    value!.select()
                    self.control.layout(cancel : .Value)
                    self.selectionView.valueEquationCheck()
                    self.equationField.inputView = self.selectionView
                    self.equationField.reloadInputViews()
                    
                    return
                }
                
                //validate (empty before input)
                if value!.valueStr.count == 1 && value!.valueStr == "0"
                {
                    let numbers : [Icon] = [.Zero, .One, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine]
                    
                    if numbers.contains(icon)
                    {
                        value!.valueStr = ""
                    }
                }
                
                //limit input
                let simulatedStr = value!.valueStr + icon.rawValue
                if value!.valueStr.count >= 19 || simulatedStr.count > 19
                {
                    return
                }
                
                //validate (prevent double-dot)
                if value!.valueStr.contains(".") && icon.rawValue == "."
                {
                    return
                }
                
                //validate
                var noCommaValueStr = self.validateByRemovingComma(fromValueStr : value!.valueStr)
                
                //re-validate
                if noCommaValueStr == "-" && icon.rawValue == "."
                {
                    noCommaValueStr += "0"
                }
                
                if (noCommaValueStr == "-0" || noCommaValueStr == "0") && icon.rawValue != "."
                {
                    noCommaValueStr = noCommaValueStr.replacingOccurrences(of: "0", with: "")
                }
                
                let valueStr = noCommaValueStr + icon.rawValue
                let validatedStr = self.validateByInsertingComma(toValueStr : valueStr)
                
                value!.valueStr     = validatedStr
                value!.value        = NSDecimalNumber(decimal : self.numberFormatter.number(from : valueStr)!.decimalValue)
            }
            
            //update state
            self.operationState     = .ValueTyping
            self.highlightedValue   = value!
            
            //highlight value
            value!.highlight()
            
            //update modifiedDate
            value!.modifiedDate     = Date()
            
            //update search
            self.search()
            
            //calculate value
            self.calculate(equation : self.currentEquation!)
            
        case .Add, .Subtract, .Multiply, .Divide :
            //validate (prevent operation without value)
            if self.currentEquation!.valueCount() == 0
            {
                return
            }
            
            //switch operation
            if self.operationState == .OnOperation
            {
                //fetch operation to delete
                let currentOperation = self.highlightedOperation!
                
                //set new type
                switch icon
                {
                case .Add           : currentOperation.type = .Add
                case .Subtract      : currentOperation.type = .Subtract
                case .Multiply      : currentOperation.type = .Multiply
                case .Divide        : currentOperation.type = .Divide
                default             : return
                }
                
                //highlight operation
                self.highlightedOperation = currentOperation
                currentOperation.highlight()
            }
            //insert operation
            else if self.operationState == .ValueTyping || self.operationState == .NameTyping
            {
                //fetch targetIndex
                let targetIndex = self.currentEquation!.fetchIndex(ofValue : self.highlightedValue!)
                
                //prepare new operation & value
                var newOperation : Operation?
                
                //set new type
                switch icon
                {
                case .Add           : newOperation = DM.createOperation(forIcon : .Add)
                case .Subtract      : newOperation = DM.createOperation(forIcon : .Subtract)
                case .Multiply      : newOperation = DM.createOperation(forIcon : .Multiply)
                case .Divide        : newOperation = DM.createOperation(forIcon : .Divide)
                default             : return
                }
                
                //validate range
                if self.currentEquation!.fetchOperations().indices.contains(targetIndex)
                {
                    let newValue = DM.createValue(forEquation : self.currentEquation!)
                
                    self.values.append(newValue)
                    
                    //add value within
                    if self.currentEquation!.fetchValues().indices.contains(targetIndex + 1)
                    {
                        self.currentEquation!.insert(value : newValue, atIndex : targetIndex + 1)
                    }
                    //append value
                    else
                    {
                        self.currentEquation!.append(value : newValue)
                    }
                    
                    //add operation within
                    self.currentEquation!.insert(operation : newOperation!, atIndex : targetIndex)
                    
                    //highlight value
                    newValue.highlight()
                }
                //append
                else
                {
                    self.currentEquation!.append(operation : newOperation!)
                    
                    //highlight operation
                    newOperation!.highlight()
                }
            }
            
            //reset equationField
            self.equationField.text = ""
            
            //calculate value
            self.calculate(equation : self.currentEquation!)
            
        default : return
            
        }
    }
    
    func pop(indexPath : IndexPath)
    {
        //block pop for last equation
        if self.currentEquations.count == 1
        {
            return
        }
        
        //fetch target index
        let index = indexPath.row
        
        //pop equation
        if self.currentEquations.indices.contains(index)
        {
            self.currentEquations.remove(at : index)
            self.equationList.deleteRows(at : [indexPath], with : .automatic)
            
            //update current equation
            var newEquation : Equation?
            
            //last
            if index - 1 == self.currentEquations.count - 1
            {
                //fetch preceding equation
                newEquation = self.currentEquations[index - 1]
            }
            //first, middleValue
            else
            {
                //fetch succeeding equation
                newEquation = self.currentEquations[index]
            }
            
            //reload current equation
            self.currentEquation = newEquation!
            self.highlightedValue = newEquation!.lastValue()
            self.highlightedState = .Value
            
            self.calculate(equation : self.currentEquation!)
            self.equationView.updateCount()
            
            self.equationList.reloadData()
        }
        
    }
    
    
    //MARK: - Button Activation
    
    
    func enable(calculatorBtns : [Icon])
    {
        if self.calculatorButtons.count == 0
        {
            return
        }
        
        for button in self.calculatorButtons
        {
            if calculatorBtns.contains(button.icon!)
            {
                button.activate()
            }
        }
    }
    
    func disable(calculatorBtns : [Icon])
    {
        if self.calculatorButtons.count == 0
        {
            return
        }
        
        for button in self.calculatorButtons
        {
            if calculatorBtns.contains(button.icon!)
            {
                button.deactivate()
            }
        }
    }
    
    func enable(keyboardBtns : [Icon])
    {
        if self.keyboardButtons.count == 0
        {
            return
        }
        
        for button in self.keyboardButtons
        {
            if keyboardBtns.contains(button.icon!)
            {
                button.activate()
            }
        }
    }
    
    func disable(keyboardBtns : [Icon])
    {
        if self.keyboardButtons.count == 0
        {
            return
        }
        
        for button in self.keyboardButtons
        {
            if keyboardBtns.contains(button.icon!)
            {
                button.deactivate()
            }
        }
    }
    
    
    //MARK: - Field Delegate
    
    
    @objc func entityFieldChanged()
    {
        //case
        switch self.fieldState
        {
        case .CreateGroup, .EditGroup   : self.entityGroup = nil; self.entityUnit = nil
        case .CreateTag, .EditTag       : self.entityUnit = nil
        default                         : break
        }

        //activate editView
        self.editView.entityView.reloadData()
    }
    
    @objc func searchFieldChanged()
    {
        //reset
        self.searchedEquations.removeAll()
        self.searchedValues.removeAll()
        self.searchedTags.removeAll()
        
        //alias
        let referenceName = self.valueField.text!.lowercased()
        
        //model
        let equations   = self.manageSelectedGroup != nil ? self.manageSelectedGroup!.fetchEquations() : self.equations
        let values      = self.manageSelectedGroup != nil ? self.manageSelectedGroup!.fetchValues() : self.values
        let tags        = self.manageSelectedGroup != nil ? self.manageSelectedGroup!.fetchTags() : self.tags
        
        //filter
        self.searchedEquations  = equations.filter({( equation : Equation) -> Bool in
                let noCommaStr  = self.validateByRemovingComma(fromValueStr : equation.valueStr)
                let valueMatch  = noCommaStr.lowercased().contains(referenceName)
                let nameMatch   = equation.name.lowercased().contains(referenceName)
                let tagMatch    = equation.fetchTags().filter({ $0.name.lowercased() == referenceName }).count != 0
                var groupMatch  = false
                if let group    = equation.group
                {
                    groupMatch  = group.name.lowercased().contains(referenceName)
                }
            
                return valueMatch || nameMatch || tagMatch || groupMatch || groupMatch
        })
        self.searchedValues = values.filter({( value : Value) -> Bool in
            let noCommaStr  = self.validateByRemovingComma(fromValueStr : value.valueStr)
            let valueMatch  = noCommaStr.lowercased().contains(referenceName)
            let nameMatch   = value.name.lowercased().contains(referenceName)
            let tagMatch    = value.fetchTags().filter({ $0.name.lowercased() == referenceName }).count != 0
            var groupMatch  = false
            if let group    = value.group
            {
                groupMatch  = group.name.lowercased().contains(referenceName)
            }
            
            return valueMatch || nameMatch || tagMatch || groupMatch
        })
        self.searchedTags   = tags.filter({( tag : Tag) -> Bool in
            let nameMatch   = tag.name.lowercased().contains(referenceName)
            
            return nameMatch
        })
        
        //update
        self.entitySegment.activateLayout()
        collection.configureManageSections()
        
        //display
        self.entitySegment.isHidden = self.valueField.text != "" ? false : true
    }
    
    
    //MARK: - Control
    
    
    func refreshControl()
    {
        //check inputAccessory
        if self.equationField.inputAccessoryView == nil
        {
            self.equationField.inputAccessoryView = self.control
        }
        
        //reload control & input
        switch self.controlState
        {
        case .Calculator :
            self.equationField.inputView = self.calculatorView
            self.control.layout(control : .Calculator)
            self.control.updateCalKeyButtons()
            
            //de-highlight calculator buttons
            for btn in self.calculatorButtons
            {
                btn.gradientLayer.activateDefault()
                btn.titleLbl?.textColor = SM.defaultColor()
            }
            
            //calculator button activation
            if self.currentEquation == self.wrongEquation && self.setting!.resetAutoSave == true
            {
                self.disable(calculatorBtns   : [.Reset])
            }
        
        case .Keyboard :
            self.equationField.inputView = nil
            self.currentEquation == self.highlightedEquation ?
                self.control.layout(control : .Calculator) : self.control.layout(control : .Keyboard)
            self.control.updateCalKeyButtons()
            
            //calculator button activation
            if self.currentEquation == self.wrongEquation && self.setting!.resetAutoSave == true
            {
                self.disable(keyboardBtns     : [.Reset])
            }
        
        case .Recent :
            self.fetchRecent()
            collection.configureRecentSections()
            
            //sort with filters
            if self.filters.filter({ $0.selected == true }).count != 0
            {
                self.applyFilters()
            }
            
            self.equationField.inputView = self.recentView
            self.control.layout(control : .Recent)
            self.control.conserveCalKeyState()
        
        case .Group :
            self.equationField.inputView = self.groupView
            self.groupView.updateLayout(withAnimation : false)
            self.control.layout(control : .Group)
            self.control.conserveCalKeyState()
        
        case .Convert :
            self.equationField.inputView = self.convertView
            self.control.layout(control : .Convert)
            self.control.conserveCalKeyState()
        
        default : break
        }
        
        //color current control
        for controlButton in self.controlButtons
        {
            if controlButton.controlState == .Calculator || controlButton.controlState == .Keyboard
            {
                controlButton.iconLbl?.textColor = self.controlState == .Calculator || self.controlState == .Keyboard ?
                                                   SM.highlightedColor() : SM.defaultColor()
            }
            else
            {
                controlButton.iconLbl?.textColor = controlButton.controlState == self.controlState ?
                SM.highlightedColor() : SM.defaultColor()
            }
        }
        
        //disable controls
        if self.currentEquation == self.highlightedEquation
        {
            //case
            if self.controlState != .Keyboard
            {
                self.control.disable(controls : [.Calculator])
                self.control.enable(controls : [.Keyboard])
            }
            else
            {
                self.control.disable(controls : [.Calculator, .Keyboard])
            }
        }
        else
        {
            self.control.enable(controls : [.Calculator, .Keyboard])
        }
        
        if !self.equationField.isFirstResponder
        {
            self.equationField.becomeFirstResponder()
        }
        
        self.equationField.reloadInputViews()
        
    }
    
    func navigateEquation(withControlState controlState : ControlState)
    {
        //defer navigation
        if self.currentEquations.count == 1
        {
            return
        }
        
        //reset
        self.valueBeforeEquation        = nil
        self.operationBeforeEquation    = nil
        
        //fetch current index
        let currentIndex = self.currentEquations.index(of : self.currentEquation!)!
        
        //previousEquation
        if controlState == .PreviousEquation
        {
            if currentIndex != 0 && currentIndex + 1 <= self.currentEquations.count
            {
                self.currentEquation = self.currentEquations[currentIndex - 1]
                self.equationView.updateCount()
            }
        }
        //nextEquation
        else
        {
            if currentIndex + 1 < self.currentEquations.count
            {
                self.currentEquation = self.currentEquations[currentIndex + 1]
                self.equationView.updateCount()
            }
        }
        
        //highlight value
        self.currentEquation!.lastValue()!.highlight()
        
        //update control, input
        self.equationField.inputView = self.calculatorView
        self.control.layout(control : .Calculator)
        self.equationField.reloadInputViews()
        
        //enable calKey switch
        self.control.enable(controls : [.Calculator, .Keyboard])
        
        //reload operationView
        self.calculate(equation : self.currentEquation!)
    }
    
    func navigateItem(withControlState controlState : ControlState)
    {
        //previous
        if controlState == .PreviousItem
        {
            //scan values
            for (index, value) in self.currentEquation!.fetchValues().enumerated()
            {
                if value == self.highlightedValue || value == self.selectedValue
                {
                    //validate range
                    if self.currentEquation!.fetchOperations().indices.contains(index - 1)
                    {
                        //fetch operationBeforeValue
                        let operationBeforeValue = self.currentEquation!.fetchOperations()[index - 1]
                        
                        //update
                        self.valueBeforeEquation        = nil
                        self.operationBeforeEquation    = operationBeforeValue
                        
                        //highlight
                        operationBeforeValue.highlight()
                        
                        //reset search
                        self.resetSearch()
                    }
                    else if value == self.currentEquation!.firstValue()
                    {
                        //validate
                        if self.currentEquation == self.wrongEquation
                        {
                            return
                        }
                        
                        //update
                        self.valueBeforeEquation        = value
                        self.operationBeforeEquation    = nil
                        
                        //highlight
                        self.currentEquation!.highlight()
                        
                        self.control.layout(control : .Calculator)
                        
                        self.equationField.inputView = nil
                        self.equationField.reloadInputViews()
                        
                        //search
                        self.search()
                    }
                    
                    //reload
                    self.unitList.reloadData()
                    
                    return
                }
            }
            
            //scan operations
            for (index, operation) in self.currentEquation!.fetchOperations().enumerated()
            {
                if operation == self.highlightedOperation || operation == self.selectedOperation
                {
                    //fetch valueBeforeOperation
                    let valueBeforeOperation = self.currentEquation!.fetchValues()[index]
                    
                    //update
                    self.valueBeforeEquation        = valueBeforeOperation
                    self.operationBeforeEquation    = nil
                    
                    //highlight
                    valueBeforeOperation.highlight()
                    
                    //search
                    self.search()
                    
                    //reload
                    self.unitList.reloadData()
                    
                    return
                }
            }
            
            //scan equation
            if self.currentEquation == self.highlightedEquation || self.currentEquation == self.selectedEquation
            {
                if self.currentEquation!.valueCount() > self.currentEquation!.operationCount()
                {
                    //fetch lastValue
                    let lastValue = self.currentEquation!.lastValue()
                    
                    //update
                    self.valueBeforeEquation        = lastValue
                    self.operationBeforeEquation    = nil
                    
                    //highlight
                    lastValue!.highlight()
                    
                    //set control to calculator
                    self.controlState = .Calculator
                    self.refreshControl()
                    
                    //search
                    self.search()
                }
                else
                {
                    //fetch lastOperation
                    let lastOperation = self.currentEquation!.lastOperation()
                    
                    //update
                    self.valueBeforeEquation        = nil
                    self.operationBeforeEquation    = lastOperation
                    
                    //highlight
                    lastOperation!.highlight()
                    
                    //reset search
                    self.resetSearch()
                }
                
                //reload
                self.unitList.reloadData()
                
                return
            }
        }
        //next
        else
        {
            //scan values
            for (index, value) in self.currentEquation!.fetchValues().enumerated()
            {
                if value == self.highlightedValue
                {
                    //validate range
                    if self.currentEquation!.fetchOperations().indices.contains(index)
                    {
                        //fetch operationAfterValue
                        let operationAfterValue = self.currentEquation!.fetchOperations()[index]
                        
                        //update
                        self.valueBeforeEquation        = nil
                        self.operationBeforeEquation    = operationAfterValue
                        
                        //highlight
                        operationAfterValue.highlight()
                        
                        //reset search
                        self.resetSearch()
                    }
                    else if value == self.currentEquation!.lastValue()
                    {
                        //validate
                        if self.currentEquation == self.wrongEquation
                        {
                            return
                        }
                        
                        //update
                        self.valueBeforeEquation        = value
                        self.operationBeforeEquation    = nil
                        
                        //highlight
                        self.currentEquation!.highlight()
                        
                        self.control.layout(control : .Calculator)
                        
                        self.equationField.inputView = nil
                        self.equationField.reloadInputViews()
                        
                        //search
                        self.search()
                    }
                    
                    //reload
                    self.unitList.reloadData()
                    
                    return
                }
            }
            
            //scan operations
            for (index, operation) in self.currentEquation!.fetchOperations().enumerated()
            {
                if operation == self.highlightedOperation
                {
                    //validate range
                    if self.currentEquation!.fetchValues().indices.contains(index + 1)
                    {
                        //fetch valueAfterOperation
                        let valueAfterOperation = self.currentEquation!.fetchValues()[index + 1]
                        
                        //update
                        self.valueBeforeEquation        = valueAfterOperation
                        self.operationBeforeEquation    = nil
                        
                        //highlight
                        valueAfterOperation.highlight()
                    }
                    else if operation == self.currentEquation!.lastOperation()
                    {
                        //validate
                        if self.currentEquation == self.wrongEquation
                        {
                            return
                        }
                        
                        //update
                        self.operationBeforeEquation    = operation
                        self.valueBeforeEquation        = nil
                        
                        //highlight
                        self.currentEquation!.highlight()
                        
                        self.control.layout(control : .Calculator)
                        
                        self.equationField.inputView = nil
                        self.equationField.reloadInputViews()
                    }
                    
                    //search
                    self.search()
                    
                    //reload
                    self.unitList.reloadData()
                    
                    return
                }
            }
            
            //scan equation
            if self.currentEquation == self.highlightedEquation
            {
                //fetch firstValue
                let firstValue = self.currentEquation!.firstValue()
                
                //update
                self.valueBeforeEquation        = firstValue
                self.operationBeforeEquation    = nil
                
                //highlight
                firstValue?.highlight()
                
                //set control to calculator
                self.controlState = .Calculator
                self.refreshControl()
                
                //search
                self.search()
                
                //reload
                self.unitList.reloadData()
                
                return
            }
        }
    }
    
    @objc func navigateLongPress(gesture : UILongPressGestureRecognizer)
    {
        let button = gesture.view as! Button
        
        switch button.controlState!
        {
        case .PreviousEquation :
            self.currentEquation = self.currentEquations.first!
            self.calculate(equation : self.currentEquation!)
        
        case .PreviousItem :
            self.currentEquation!.firstValue()!.highlight()
            self.operationView.reloadData()
        
        case .NextItem :
            self.currentEquation!.lastValue()!.highlight()
            self.operationView.reloadData()
        
        case .NextEquation :
            self.currentEquation = self.currentEquations.last!
            self.calculate(equation : self.currentEquation!)
        
        default : return
        }
    }
    
    func selectItem()
    {
        //update operationState
        if self.operationState != .OnSelection
        {
            self.operationState = .OnSelection
        }
        else
        {
            self.operationState = self.controlState == .Calculator ? .ValueTyping : .NameTyping
        }
        
        //glow select
        let selectBtn = self.controlButtons.filter({ $0.iconLbl!.text == Icon.Select.rawValue }).first!
        selectBtn.iconLbl?.textColor = selectBtn.iconLbl?.textColor == .red ? .black : .red
        
        //select highlighted
        switch self.highlightedState
        {
        case .Equation :
            self.equationView.equationTapped()
        
        case .Value :
            SM.adjustSelection(withState : .Value)
            
            //activate value
            self.highlightedValue?.select()
            
            self.control.layout(cancel : .Value)
            
            self.selectFrom = .Operation
            self.selectionView.value(selectFrom : self.selectFrom)
            self.equationField.inputView = self.selectionView
            self.equationField.reloadInputViews()
            
            //display infoView
            self.infoView.show()
        
        case .Operation : return
            
        }

    }
    
    
    //MARK: - Calculator
    
    
    func reset()
    {
        /* reset */
        
        //check if equationValue exists
        if let equationValue = DM.fetchValue(withEquationUID : self.currentEquation!.uid)
        {
            equationValue.valueStr      = "0"
            equationValue.value         = NSDecimalNumber(decimal : self.numberFormatter.number(from : equationValue.valueStr)!.decimalValue)
            equationValue.isEquation    = false
        }
        
        //delete values
        for value in self.currentEquation!.fetchValues()
        {
            //de-link
            if value.isEquation == true
            {
                let equation = DM.fetchEquation(forUID : value.uid)
                equation?.uid = DM.createUID()
                value.isEquation = false
            }
            
            value.belongTo = ""
            
            //remove from arrays
            if self.values.contains(value)
            {
                self.values.remove(at : self.values.index(of : value)!)
            }
            if self.recentValues.contains(value)
            {
                self.recentValues.remove(at : self.recentValues.index(of : value)!)
            }
            
            //delete value mo
            DM.managedObjectContext.delete(value)
        }
        
        //delete operations
        for operation in self.currentEquation!.fetchOperations()
        {
            //delete value mo
            DM.managedObjectContext.delete(operation)
        }
        
        //delete current equation
        if self.equations.contains(self.currentEquation!)
        {
            self.equations.remove(at : self.equations.index(of : self.currentEquation!)!)
        }
        if self.recentEquations.contains(self.currentEquation!)
        {
            self.recentEquations.remove(at : self.recentEquations.index(of : self.currentEquation!)!)
        }
        
        //refresh objects
//        for mo in DM.managedObjectContext.registeredObjects
//        {
//            DM.managedObjectContext.refresh(mo, mergeChanges : false)
//        }
        
        self.valueField.text = ""
        self.equationField.text = ""
        self.searchedValues.removeAll()
        
        //reload current equation
        let currentIndex = self.currentEquations.index(of : self.currentEquation!)!
        DM.managedObjectContext.delete(self.currentEquation!)
        DM.saveContext()
        
        //reload current equation
        let newEquation = DM.fetchInventoryEquation()
        
        if self.currentEquations.contains(newEquation)
        {
            for equation in self.currentEquations
            {
                if equation == newEquation
                {
                    self.currentEquations.remove(at : currentIndex)
                    self.currentEquation = equation
                    break
                }
            }
        }
        else
        {
            self.currentEquations[currentIndex] = newEquation
            self.currentEquation = self.currentEquations[currentIndex]
        }
        
        if !self.equations.contains(self.currentEquation!)
        {
            self.equations.append(self.currentEquation!)
        }
        if !self.values.contains(self.currentEquation!.firstValue()!)
        {
            self.values.append(self.currentEquation!.firstValue()!)
        }
        if !self.recentValues.contains(self.currentEquation!.firstValue()!)
        {
            self.recentValues.append(self.currentEquation!.firstValue()!)
        }
        
        //highlight
        self.currentEquation!.lastValue()?.highlight()
        
        //update state
        self.operationState = .ValueTyping
        
        //reset search
        self.resetSearch()
        
        //update calculate
        self.equationView.updateCount()
        self.calculate(equation : self.currentEquation!)
        
        //refresh control
        self.refreshControl()
    }
    
    func saveReset()
    {
        //update calculation
        self.calculate(equation : self.currentEquation!)
        
        //reset
        self.valueField.text = ""
        self.equationField.text = ""
        self.searchedValues.removeAll()
        self.valueBeforeEquation        = nil
        self.operationBeforeEquation    = nil
        
        //validate & delete (check if equation holds single value)
        if self.currentEquation!.valueCount() == 1 && self.currentEquation!.operationCount() == 0
        {
            //check if equation is a sub & detach
            if let equationValue = DM.fetchValue(withEquationUID : self.currentEquation!.uid)
            {
                equationValue.isEquation = false
                self.currentEquation!.uid = DM.createUID()
            }
            
            if self.currentEquation!.name == "" && self.currentEquation!.unit == nil && self.currentEquation!.group == nil
            {
                let firstValue = self.currentEquation!.firstValue()!
                
                if !(firstValue.name == "" && firstValue.value == 0 && firstValue.isEquation == false)
                {
                    //update date
                    firstValue.recentDate = Date()
                    
                    //remove value
                    self.currentEquation!.remove(value : firstValue)
                    
                    //create value
                    let newValue = DM.createValue(forEquation : self.currentEquation!)
                    newValue.highlight()
                    
                    //append value
                    self.currentEquation!.append(value : newValue)
                    
                    //add current equation and starting value
                    if !self.equations.contains(self.currentEquation!)
                    {
                        self.equations.append(self.currentEquation!)
                    }
                    if !self.values.contains(self.currentEquation!.firstValue()!)
                    {
                        self.values.append(self.currentEquation!.firstValue()!)
                    }
                    if !self.recentValues.contains(self.currentEquation!.firstValue()!)
                    {
                        self.recentValues.append(self.currentEquation!.firstValue()!)
                    }
                    
                    //save
                    DM.saveContext()
                    
                    //refresh objects
                    for mo in DM.managedObjectContext.registeredObjects
                    {
                        DM.managedObjectContext.refresh(mo, mergeChanges : false)
                    }
                    
                    //highlight
                    self.currentEquation!.lastValue()?.highlight()
                    
                    //reset search
                    self.resetSearch()
                    
                    //update calculate
                    self.equationView.updateCount()
                    
                    self.calculate(equation : self.currentEquation!)
                    
                    //refresh control
                    self.refreshControl()
                    
                    return
                }
            }
        }
        
        //update date
        self.currentEquation!.recentDate = Date()
        
        //fetch current index
        let currentIndex = self.currentEquations.index(of : self.currentEquation!)!
        
        //reload current equation
        let newEquation = DM.fetchInventoryEquation()
        
        if self.currentEquations.contains(newEquation)
        {
            for equation in self.currentEquations
            {
                if equation == newEquation && equation != self.currentEquation
                {
                    self.currentEquations.remove(at : currentIndex)
                    self.currentEquation = equation
                    break
                }
            }
        }
        else
        {
            self.currentEquations[currentIndex] = newEquation
            self.currentEquation = self.currentEquations[currentIndex]
        }
        
        //add current equation and starting value
        if !self.equations.contains(self.currentEquation!)
        {
            self.equations.append(self.currentEquation!)
        }
        if !self.values.contains(self.currentEquation!.firstValue()!)
        {
            self.values.append(self.currentEquation!.firstValue()!)
        }
        if !self.recentValues.contains(self.currentEquation!.firstValue()!)
        {
            self.recentValues.append(self.currentEquation!.firstValue()!)
        }
        
        //save
        DM.saveContext()
        
        //refresh objects
        for mo in DM.managedObjectContext.registeredObjects
        {
            DM.managedObjectContext.refresh(mo, mergeChanges : false)
        }
        
        //highlight
        self.currentEquation!.lastValue()?.highlight()
        
        //reset search
        self.resetSearch()
        
        //update calculate
        self.equationView.updateCount()
        
        self.calculate(equation : self.currentEquation!)
        
        //refresh control
        self.refreshControl()
    }
    
    func backspace()
    {
        switch self.highlightedState
        {
        case .Equation :
            self.currentEquation!.name          = String(self.currentEquation!.name.dropLast())
            self.equationField.text             = self.currentEquation!.name
            self.calculate(equation : self.currentEquation!)
            
            //update modifiedDate
            self.currentEquation!.modifiedDate  = Date()
            
            //search
            self.search()
            
            return
        
        case .Operation :
            let index = self.currentEquation!.fetchIndex(ofOperation : self.highlightedOperation!)
            
            //fetch value before operation
            let valueBeforeOperation = self.currentEquation!.fetchValues()[index]
            
            /* validate */
            
            //value exists after target operation
            if self.currentEquation!.fetchValues().indices.contains(index + 1)
            {
                self.currentEquation!.remove(value : valueBeforeOperation)
                
                //delete target operation
                self.currentEquation!.remove(operation : self.highlightedOperation!)
                
                //fetch replaced value
                let replacedValue = self.currentEquation!.fetchValues()[index]
                replacedValue.highlight()
            }
            //value does not exist after target operation
            else
            {
                //fill equationField former value name
                self.equationField.text = valueBeforeOperation.name
                
                //delete target operation
                self.currentEquation!.remove(operation : self.highlightedOperation!)
                
                //highlight value before removing operation
                valueBeforeOperation.highlight()
            }
            
            //search
            self.search()
            
            //update state
            self.operationState = self.controlState == .Calculator ? .ValueTyping : .NameTyping
        
        case .Value :
            let value = self.highlightedValue!
            let valueIndex = self.currentEquation!.fetchIndex(ofValue : value)
            var plainValueStr = self.validateByRemovingComma(fromValueStr : value.valueStr)
            
            //first
            if value == self.currentEquation!.firstValue()
            {
                if plainValueStr == "0" && value.name == ""
                {
                    return
                }
                else if plainValueStr == "0" && value.name != ""
                {
                    value.name              = String(value.name.dropLast())
                    self.equationField.text = value.name
                    
                    //update modifiedDate
                    value.modifiedDate      = Date()
                    
                    //update search
                    self.search()
                }
                else if plainValueStr != "0" && value.name == ""
                {
                    //value has one character
                    if plainValueStr.count == 1
                    {
                        value.valueStr  = "0"
                        value.value     = NSDecimalNumber(decimal : self.numberFormatter.number(from :
                                                                    value.valueStr)!.decimalValue)
                    }
                    //value has more than one character
                    else
                    {
                        plainValueStr   = String(plainValueStr.dropLast())
                        value.valueStr  = self.validateByInsertingComma(toValueStr : plainValueStr)
                        
                        if plainValueStr == "-"
                        {
                            value.value = 0
                        }
                        else
                        {
                            value.value = NSDecimalNumber(decimal : self.numberFormatter.number(from :
                                                                    plainValueStr)!.decimalValue)
                        }
                    }
                    
                    //update modifiedDate
                    value.modifiedDate  = Date()
                    
                    //update search
                    self.search()
                }
                else
                {
                    if self.controlState == .Keyboard
                    {
                        value.name              = String(value.name.dropLast())
                        self.equationField.text = value.name
                    }
                    else
                    {
                        if plainValueStr.count == 1
                        {
                            value.valueStr      = "0"
                            value.value         = NSDecimalNumber(decimal : self.numberFormatter.number(from :
                                                                            value.valueStr)!.decimalValue)
                        }
                        else
                        {
                            plainValueStr       = String(plainValueStr.dropLast())
                            value.valueStr      = self.validateByInsertingComma(toValueStr : plainValueStr)
                            
                            if plainValueStr == "-"
                            {
                                value.value     = 0
                            }
                            else
                            {
                                value.value     = NSDecimalNumber(decimal : self.numberFormatter.number(from :
                                                                            plainValueStr)!.decimalValue)
                            }
                        }
                    }
                    
                    //update modifiedDate
                    value.modifiedDate          = Date()
                    
                    //update search
                    self.search()
                }
                
                //update state
                self.operationState = self.controlState == .Calculator ? .ValueTyping : .NameTyping
            }
            //middle, last
            else
            {
                //middle (has operation after targetValue)
                if self.currentEquation!.fetchOperations().indices.contains(valueIndex)
                {
                    if plainValueStr == "0" && value.name == ""
                    {
                        let operationBeforeValue = self.currentEquation!.fetchOperations()[valueIndex - 1]
                        let valueBeforeValue = self.currentEquation!.fetchValues()[valueIndex - 1]
                        
                        self.currentEquation!.remove(value : value)
                        self.currentEquation!.remove(operation : operationBeforeValue)
                        
                        DM.delete(value : value)
                        valueBeforeValue.highlight()
                        
                        //update search
                        self.search()
                        
                        //update state
                        self.operationState = self.controlState == .Calculator ? .ValueTyping : .NameTyping
                    }
                    else if plainValueStr == "0" && value.name != ""
                    {
                        value.name              = String(value.name.dropLast())
                        self.equationField.text = value.name
                        
                        //update modifiedDate
                        value.modifiedDate      = Date()
                        
                        //update search
                        self.search()
                        
                        //update state
                        self.operationState = self.controlState == .Calculator ? .ValueTyping : .NameTyping
                    }
                    else if plainValueStr != "0" && value.name == ""
                    {
                        //value has one character
                        if plainValueStr.count == 1
                        {
                            value.valueStr      = "0"
                            value.value         = NSDecimalNumber(decimal : self.numberFormatter.number(from :
                                                                            value.valueStr)!.decimalValue)
                            
                            //update state
                            self.operationState = self.controlState == .Calculator ? .ValueTyping : .NameTyping
                            
                            //reset search
                            self.resetSearch()
                        }
                        //value has more than one character
                        else
                        {
                            plainValueStr       = String(plainValueStr.dropLast())
                            value.valueStr      = self.validateByInsertingComma(toValueStr : plainValueStr)
                            
                            if plainValueStr == "-"
                            {
                                value.value     = 0
                            }
                            else
                            {
                                value.value     = NSDecimalNumber(decimal : self.numberFormatter.number(from :
                                                                            plainValueStr)!.decimalValue)
                            }
                            
                            //update search
                            self.search()
                        }
                        
                        //update modifiedDate
                        value.modifiedDate      = Date()
                        
                        //update state
                        self.operationState     = self.controlState == .Calculator ? .ValueTyping : .NameTyping
                    }
                    else
                    {
                        if self.controlState == .Keyboard
                        {
                            value.name              = String(value.name.dropLast())
                            self.equationField.text = value.name
                            
                            //update search
                            self.search()
                        }
                        else
                        {
                            if plainValueStr.count == 1
                            {
                                value.valueStr  = "0"
                                value.value     = NSDecimalNumber(decimal : self.numberFormatter.number(from :
                                                                            value.valueStr)!.decimalValue)
                            }
                            else
                            {
                                plainValueStr   = String(plainValueStr.dropLast())
                                value.valueStr  = self.validateByInsertingComma(toValueStr : plainValueStr)
                                
                                if plainValueStr == "-"
                                {
                                    value.value = 0
                                }
                                else
                                {
                                    value.value = NSDecimalNumber(decimal : self.numberFormatter.number(from :
                                                                            plainValueStr)!.decimalValue)
                                }
                                
                                //update search
                                self.search()
                            }
                        }
                        
                        //update modifiedDate
                        value.modifiedDate      = Date()
                        
                        //update state
                        self.operationState     = self.controlState == .Calculator ? .ValueTyping : .NameTyping
                    }
                }
                //last (has no operation after targetValue)
                else
                {
                    if plainValueStr == "0" && value.name == ""
                    {
                        let operationBeforeValue = self.currentEquation!.fetchOperations()[valueIndex - 1]
                        operationBeforeValue.highlight()
                        
                        self.currentEquation!.remove(value : value)
                        DM.delete(value : value)
                        
                        //update state
                        self.operationState = .OnOperation
                        
                        //reset search
                        self.resetSearch()
                    }
                    else if plainValueStr == "0" && value.name != ""
                    {
                        //name has one character
                        if value.name.count == 1
                        {
                            let operationBeforeValue = self.currentEquation!.fetchOperations()[valueIndex - 1]
                            operationBeforeValue.highlight()
                            
                            self.currentEquation!.remove(value : value)
                            DM.delete(value : value)
                            
                            //update state
                            self.operationState = .OnOperation
                            
                            //reset search
                            self.resetSearch()
                        }
                        //name has more than one character
                        else
                        {
                            value.name              = String(value.name.dropLast())
                            self.equationField.text = value.name
                            
                            //update modifiedDate
                            value.modifiedDate      = Date()
                            
                            //update search
                            self.search()
                            
                            //update state
                            self.operationState = self.controlState == .Calculator ? .ValueTyping : .NameTyping
                        }
                    }
                    else if plainValueStr != "0" && value.name == ""
                    {
                        //value has one character
                        if plainValueStr.count == 1
                        {
                            let operationBeforeValue = self.currentEquation!.fetchOperations()[valueIndex - 1]
                            operationBeforeValue.highlight()
                            
                            self.currentEquation!.remove(value : value)
                            DM.delete(value : value)
                            
                            //update state
                            self.operationState = .OnOperation
                            
                            //reset search
                            self.resetSearch()
                        }
                        //value has more than one character
                        else
                        {
                            plainValueStr       = String(plainValueStr.dropLast())
                            value.valueStr      = self.validateByInsertingComma(toValueStr : plainValueStr)
                            
                            if plainValueStr == "-"
                            {
                                value.value     = 0
                            }
                            else
                            {
                                value.value     = NSDecimalNumber(decimal : self.numberFormatter.number(from : plainValueStr)!.decimalValue)
                            }
                            
                            //update modifiedDate
                            value.modifiedDate  = Date()
                            
                            //update search
                            self.search()
                            
                            //update state
                            self.operationState = self.controlState == .Calculator ? .ValueTyping : .NameTyping
                        }
                    }
                    else
                    {
                        if self.controlState == .Keyboard
                        {
                            value.name              = String(value.name.dropLast())
                            self.equationField.text = value.name
                            
                            //update search
                            self.search()
                        }
                        else
                        {
                            if plainValueStr.count == 1
                            {
                                value.valueStr  = "0"
                                value.value     = NSDecimalNumber(decimal : self.numberFormatter.number(from :
                                                                            value.valueStr)!.decimalValue)
                            }
                            else
                            {
                                plainValueStr   = String(plainValueStr.dropLast())
                                value.valueStr  = self.validateByInsertingComma(toValueStr : plainValueStr)
                                
                                if plainValueStr == "-"
                                {
                                    value.value = 0
                                }
                                else
                                {
                                    value.value = NSDecimalNumber(decimal : self.numberFormatter.number(from : plainValueStr)!.decimalValue)
                                }
                                
                                //update search
                                self.search()
                            }
                        }
                        
                        //update modifiedDate
                        value.modifiedDate  = Date()
                        
                        //update state
                        self.operationState = self.controlState == .Calculator ? .ValueTyping : .NameTyping
                    }
                }
            }
            
        }
        
        //reload
        self.calculate(equation : self.currentEquation!)
    }
    
    @objc func backspaceLongPress(gesture : UILongPressGestureRecognizer)
    {
        if self.highlightedState == .Value
        {
            if self.highlightedValue!.isEquation == true
            {
                return
            }
            
            self.highlightedValue?.name       = ""
            self.highlightedValue?.valueStr   = "0"
            self.highlightedValue?.value      = NSDecimalNumber(decimal : self.numberFormatter.number(from :
                                                self.highlightedValue!.valueStr)!.decimalValue)
        }
        
        //reload
        self.calculate(equation : self.currentEquation!)
        
        //view
        let view = gesture.view
        
        //bifurcate
        if view is Button
        {
            let button = view as! Button
            
            //de-gradient
            button.gradientLayer.activateDefault()
            button.titleLbl?.textColor = SM.defaultColor()
        }
        else
        {
            let button = view as! ShadowButton
            
            //de-highlight
            button.gradientLayer.activateKeyDefault()
            button.iconLbl.textColor  = SM.keyTitleColor()
        }
    }
    
    
    //MARK: - Calculator Engine
    
    
    //real-time calculation
    func calculate(equation : Equation)
    {
        
        
        //fetch model
        let equationUnit                = equation.unit != nil
        var valueItems  : [ValueItem]   = equation.valueItems()
        var operations  : [Operation]   = equation.fetchOperations()
        
        //execute firsthand (multiply & divide operation)
        for operation in operations
        {
            if operation.type == .Multiply || operation.type == .Divide
            {
                //prepare
                let operationIndex      = operations.index(of : operation)!
                let endIndex : Int      = valueItems.indices.contains(operationIndex + 1) ?
                                          operationIndex + 1 : operationIndex
                
                var vi  : ValueItem
                let fvi : ValueItem     = valueItems[operationIndex]
                let lvi : ValueItem?    = valueItems.indices.contains(operationIndex + 1) ?
                                          valueItems[operationIndex + 1] : nil
                
                if lvi != nil
                {
                    switch operation.type
                    {
                    case .Multiply  : vi = fvi.convertible(to : lvi!) ? fvi * lvi! : fvi.multiplying(target : lvi!)
                    case .Divide    :
                        //validate
                        if lvi!.value == 0
                        {
                            //register equation as wrong
                            self.registerEquation(wrong : true)
                            return
                        }
                        
                        //de-register equation as wrong
                        self.registerEquation(wrong : false)
                        
                        vi = fvi.convertible(to : lvi!) ? fvi / lvi! : fvi.dividing(target : lvi!)
                        
                    default : return
                    }
                    valueItems.replaceSubrange(Range(operationIndex...endIndex), with : [vi])
                }
                
                //remove used operation
                operations.remove(at : operationIndex)
            }
        }
        
        //execute secondhand (add & substract operation)
        for operation in operations
        {
            //prepare
            let operationIndex      = operations.index(of : operation)!
            let endIndex : Int      = valueItems.indices.contains(operationIndex + 1) ?
                                      operationIndex + 1 : operationIndex
            
            var vi  : ValueItem
            let fvi : ValueItem     = valueItems[operationIndex]
            let lvi : ValueItem?    = valueItems.indices.contains(operationIndex + 1) ?
                                      valueItems[operationIndex + 1] : nil
            
            if lvi != nil
            {
                switch operation.type
                {
                case .Add       : vi = fvi.convertible(to : lvi!) ? fvi + lvi! : fvi.adding(target : lvi!)
                case .Subtract  : vi = fvi.convertible(to : lvi!) ? fvi - lvi! : fvi.subtracting(target : lvi!)
                default         : return
                }
                valueItems.replaceSubrange(Range(operationIndex...endIndex), with : [vi])
            }
            
            //remove used operation
            operations.remove(at : operationIndex)
        }
        
        //de-register equation as wrong
        self.registerEquation(wrong : false)
        
        //update equation
        if equation.fetchValues().filter({ $0.unit != nil }).count != 0
        {
            equation.unit   = equationUnit ? valueItems.last!.convertible(to : equation) ?
                              equation.unit : valueItems.last!.unit : valueItems.last!.unit
        }
        
        equation.value      = valueItems.last!.convertible(to : equation) ?
                              valueItems.last!.converted(equation.unit!).value : valueItems.last!.value
        equation.valueStr   = self.numberFormatter.string(from : equation.value)!
        
        
        //update value for equation
        if let holdingValue = DM.fetchValue(withEquationUID : equation.uid)
        {
            holdingValue.name      = equation.name
            holdingValue.value     = equation.value
            holdingValue.valueStr  = equation.valueStr
            holdingValue.unit      = equation.unit
            
            //update holding equation for holding value
            if let holdingEquation = DM.fetchEquation(forUID : holdingValue.belongTo)
            {
                self.calculate(equation : holdingEquation)
            }
        }
        
        //activate equation
        self.equationView.activateEquation()
        
        //reload
        self.operationView.reloadData()
        
        //align operation items
        switch self.highlightedState
        {
        case .Value :
            if self.currentEquation!.fetchValues().contains(self.highlightedValue!)
            {
                let valueIndex  = self.currentEquation!.fetchValues().index(of : self.highlightedValue!)!
                let item        = valueIndex * 2
                let indexPath   = IndexPath(item : item, section : 0)
                
                self.operationView.scrollToItem(at : indexPath, at : .centeredVertically, animated : false)
            }
            
        case .Operation :
            if self.currentEquation!.fetchOperations().contains(self.highlightedOperation!)
            {
                let operationIndex  = self.currentEquation!.fetchOperations().index(of : self.highlightedOperation!)!
                let item            = (operationIndex * 2) + 1
                let indexPath       = IndexPath(item : item, section : 0)
                
                self.operationView.scrollToItem(at : indexPath, at : .centeredVertically, animated : false)
            }
            
        default : break
        }
        
        //save
        DM.saveContext()
        
        //flush
        valueItems.removeAll()
    }
    
    func registerEquation(wrong : Bool)
    {
        if wrong
        {
            //register as wrong equation
            self.wrongEquation = self.currentEquation
            
            //control button activation
            self.control.disable(controls : [.Select, .Recent, .Group, .Convert, .PreviousEquation, .NextEquation])
            
            //calculator button activation
            if self.setting!.resetAutoSave == true
            {
                self.disable(calculatorBtns   : [.Reset])
                self.disable(keyboardBtns     : [.Reset])
            }
            
            //display error
            self.equationView.activateError(withDescription : "#calculationErrorCaption".local)
            
            //reload
            self.operationView.reloadData()
        }
        else
        {
            //de-register as wrong equation
            self.wrongEquation = nil
            
            //control button activation
            if self.highlightedState != .Operation
            {
                self.control.enable(controls : [.Select])
            }
            self.control.enable(controls : [.Recent, .Group, .Convert, .PreviousEquation, .NextEquation])
            
            //calculator button activation
            self.enable(calculatorBtns   : [.Reset])
            self.enable(keyboardBtns     : [.Reset])
        }
    }
 
 
    //MARK: - Operation Search
    
    
    func search()
    {
        //reset
        self.searchedEquations.removeAll()
        self.searchedValues.removeAll()
        
        //prepare
        var duplicateEquations  = [Equation]()
        var duplicateValues     = [Value]()
    
        //filter
        switch self.highlightedState
        {
        case .Equation :
            let equation = self.highlightedEquation!
            
            //has only name
            if equation.name != "" && equation.value == 0
            {
                //filter
                self.searchedEquations = self.equations.filter({(searchedEquation : Equation) -> Bool in
                    let nameMatch   = searchedEquation.name.lowercased().contains(equation.name.lowercased())
                    let notCurrent  = searchedEquation != equation
                    
                    return nameMatch && notCurrent
                })
                self.searchedValues = self.values.filter({(searchedValue : Value) -> Bool in
                    let nameMatch   = searchedValue.name.lowercased().contains(equation.name.lowercased())
                    let notCurrent  = !equation.fetchValues().contains(searchedValue)
                    
                    return nameMatch && notCurrent
                })
            }
            //has only value
            else if equation.name == "" && equation.value != 0
            {
                //filter
                self.searchedEquations = self.equations.filter({(searchedEquation : Equation) -> Bool in
                    let noCommaStr  = self.validateByRemovingComma(fromValueStr : searchedEquation.valueStr)
                    let valueMatch  = noCommaStr.lowercased().contains(equation.valueStr.lowercased())
                    let notCurrent  = searchedEquation != equation
                    
                    return valueMatch && notCurrent
                })
                self.searchedValues = self.values.filter({(searchedValue : Value) -> Bool in
                    let noCommaStr  = self.validateByRemovingComma(fromValueStr : searchedValue.valueStr)
                    let valueMatch  = noCommaStr.lowercased().contains(equation.valueStr.lowercased())
                    let notCurrent  = !equation.fetchValues().contains(searchedValue)
                    
                    return valueMatch && notCurrent
                })
            }
            //has both
            else if equation.name != "" && equation.value != 0
            {
                //filter value
                self.searchedEquations = self.equations.filter({(searchedEquation : Equation) -> Bool in
                    let noCommaStr  = self.validateByRemovingComma(fromValueStr : searchedEquation.valueStr)
                    let valueMatch  = noCommaStr.lowercased().contains(equation.valueStr.lowercased())
                    let nameMatch   = searchedEquation.name.lowercased().contains(equation.name.lowercased())
                    let notCurrent  = searchedEquation != equation
                    
                    return valueMatch && nameMatch && notCurrent
                })
                self.searchedValues = self.values.filter({(searchedValue : Value) -> Bool in
                    let noCommaStr  = self.validateByRemovingComma(fromValueStr : searchedValue.valueStr)
                    let valueMatch  = noCommaStr.lowercased().contains(equation.valueStr.lowercased())
                    let nameMatch   = searchedValue.name.lowercased().contains(equation.name.lowercased())
                    let notCurrent  = !equation.fetchValues().contains(searchedValue)
                    
                    return valueMatch && nameMatch && notCurrent
                })
            }
            //has none
            else
            {
                self.searchedEquations.removeAll()
                self.searchedValues.removeAll()
            }
        
        case .Value :
            let value = self.highlightedValue!
            
            //has only name
            if value.name != "" && value.value == 0
            {
                //filter
                self.searchedEquations = self.equations.filter({(searchedEquation : Equation) -> Bool in
                    let nameMatch   = searchedEquation.name.lowercased().contains(value.name.lowercased())
                    let notCurrent  = searchedEquation != self.currentEquation
                    
                    return nameMatch && notCurrent
                })
                self.searchedValues = self.values.filter({(searchedValue : Value) -> Bool in
                    let nameMatch   = searchedValue.name.lowercased().contains(value.name.lowercased())
                    let notCurrent  = searchedValue != value
                    
                    return nameMatch && notCurrent
                })
            }
            //has only value
            else if value.name == "" && value.value != 0
            {
                //filter
                self.searchedEquations = self.equations.filter({(searchedEquation : Equation) -> Bool in
                    let noCommaStr  = self.validateByRemovingComma(fromValueStr : searchedEquation.valueStr)
                    let valueMatch  = noCommaStr.lowercased().contains(value.valueStr.lowercased())
                    let notCurrent  = searchedEquation != self.currentEquation
                    
                    return valueMatch && notCurrent
                })
                self.searchedValues = self.values.filter({(searchedValue : Value) -> Bool in
                    let noCommaStr  = self.validateByRemovingComma(fromValueStr : searchedValue.valueStr)
                    let valueMatch  = noCommaStr.lowercased().contains(value.valueStr.lowercased())
                    let notCurrent  = searchedValue != value
                    
                    return valueMatch && notCurrent
                })
            }
            //has both
            else if value.name != "" && value.value != 0
            {
                //filter value
                self.searchedEquations = self.equations.filter({(searchedEquation : Equation) -> Bool in
                    let noCommaStr  = self.validateByRemovingComma(fromValueStr : searchedEquation.valueStr)
                    let valueMatch  = noCommaStr.lowercased().contains(value.valueStr.lowercased())
                    let nameMatch   = searchedEquation.name.lowercased().contains(value.name.lowercased())
                    let notCurrent  = searchedEquation != self.currentEquation
                    
                    return valueMatch && nameMatch && notCurrent
                })
                self.searchedValues = self.values.filter({(searchedValue : Value) -> Bool in
                    let noCommaStr  = self.validateByRemovingComma(fromValueStr : searchedValue.valueStr)
                    let valueMatch  = noCommaStr.lowercased().contains(value.valueStr.lowercased())
                    let nameMatch   = searchedValue.name.lowercased().contains(value.name.lowercased())
                    let notCurrent  = searchedValue != value
                    
                    return valueMatch && nameMatch && notCurrent
                })
            }
            //has none
            else
            {
                self.searchedEquations.removeAll()
                self.searchedValues.removeAll()
            }
        
        default : return
        }
        
        //filter entities with tag
        let referenceName = self.highlightedState == .Equation ? self.highlightedEquation!.name : self.highlightedValue!.name
        for equation in self.equations
        {
            if equation.fetchTags().filter({ $0.name.lowercased() == referenceName.lowercased() }).count != 0
            {
                if !self.searchedEquations.contains(equation)
                {
                    searchedEquations.append(equation)
                }
            }
        }
        for _value in self.values
        {
            if _value.fetchTags().filter({ $0.name.lowercased() == referenceName.lowercased() }).count != 0
            {
                if !self.searchedValues.contains(_value)
                {
                    self.searchedValues.append(_value)
                }
            }
        }
        
        //search duplicate equations
        for i in 0..<self.searchedEquations.count
        {
            //reference equation
            let equationI = self.searchedEquations[i]
            
            //append duplicate
            for j in i+1..<self.searchedEquations.count
            {
                //comparing value
                let equationJ = self.searchedEquations[j]
                
                if equationI.name == equationJ.name
                {
                    if equationI.valueStr == equationJ.valueStr
                    {
                        duplicateEquations.append(equationJ)
                    }
                }
            }
            
            //apppend highlighted entity
            if let equation = self.highlightedEquation
            {
                if equationI.name == equation.name && equationI.valueStr == equation.valueStr
                {
                    if (equationI.createdDate.compare(equation.createdDate as Date)) == .orderedSame
                    {
                        duplicateEquations.append(equationI)
                    }
                }
            }
            else if let value = self.highlightedValue
            {
                if equationI.name == value.name && equationI.valueStr == value.valueStr
                {
                    if (equationI.createdDate.compare(value.createdDate as Date)) == .orderedSame
                    {
                        duplicateEquations.append(equationI)
                    }
                }
            }
        }
        
        //search duplicate values
        for i in 0..<self.searchedValues.count
        {
            //reference value
            let valueI = self.searchedValues[i]
            
            //append duplicate
            for j in i+1..<self.searchedValues.count
            {
                //comparing value
                let valueJ = self.searchedValues[j]
                
                if valueI.name == valueJ.name
                {
                    if valueI.valueStr == valueJ.valueStr
                    {
                        duplicateValues.append(valueJ)
                    }
                }
            }
            
            //append highlighted entity
            if let equation = self.highlightedEquation
            {
                if valueI.name == equation.name && valueI.valueStr == equation.valueStr
                {
                    if (valueI.createdDate.compare(equation.createdDate as Date)) == .orderedSame
                    {
                        duplicateValues.append(valueI)
                    }
                }
            }
            else if let value = self.highlightedValue
            {
                if valueI.name == value.name && valueI.valueStr == value.valueStr
                {
                    if (valueI.createdDate.compare(value.createdDate as Date)) == .orderedSame
                    {
                        duplicateValues.append(valueI)
                    }
                }
            }
        }
        
        //remove duplicates
        for duplicateEquation in duplicateEquations
        {
            if self.searchedEquations.contains(duplicateEquation)
            {
                self.searchedEquations.remove(at : self.searchedEquations.index(of : duplicateEquation)!)
            }
        }
        for duplicateValue in duplicateValues
        {
            if self.searchedValues.contains(duplicateValue)
            {
                self.searchedValues.remove(at : self.searchedValues.index(of : duplicateValue)!)
            }
        }
        
        //limit to 100
        self.searchedEquations  = self.searchedEquations.enumerated().compactMap{ $0.offset < 100 ? $0.element : nil }
        self.searchedValues     = self.searchedValues.enumerated().compactMap{ $0.offset < 100 ? $0.element : nil }
        
//        self.searchedEquations  = self.searchedEquations.enumerated().flatMap()
        
        //sort by createdDate
        self.searchedEquations  = self.searchedEquations.sorted(by : { v1, v2 in v1.recentDate < v2.recentDate })
        self.searchedValues     = self.searchedValues.sorted(by : { v1, v2 in v1.recentDate < v2.recentDate })
        
        //reload
        self.searchView.reloadData()
    }
    
    func resetSearch()
    {
        self.searchedEquations.removeAll()
        self.searchedValues.removeAll()
        
        if self.equationField.text != ""
        {
            self.search()
        }
    
        self.searchView.reloadData()
    }
    
    
    //MARK: - Validator
    
    
    func validateByRemovingComma(fromValueStr valueStr : String) -> String
    {
        //erase comma
        if valueStr.contains(",")
        {
            return valueStr.replacingOccurrences(of : ",", with : "")
        }
        return valueStr
    }
    
    func validateByInsertingComma(toValueStr valueStr : String) -> String
    {
        //decimal
        if valueStr.contains(".")
        {
            let decimalStrArr = valueStr.components(separatedBy : ".")
            let beforeDot = decimalStrArr[0]
            let afterDot = decimalStrArr[1]
            
            //re-validate
            if self.operationState == .ValueTyping
            {
                var validatedBeforeDot = self.validateByInsertingComma(toValueStr : beforeDot)
                validatedBeforeDot += "."
                validatedBeforeDot += afterDot
                return validatedBeforeDot
            }
            else if afterDot == "0"
            {
                return self.numberFormatter.string(from : NSDecimalNumber(string : valueStr))!
            }
            
            if (beforeDot.count >= 4 && !beforeDot.contains("-") || beforeDot.count >= 5 && beforeDot.contains("-"))
            {
                return self.numberFormatter.string(from : NSDecimalNumber(string : valueStr))!
            }
            else
            {
                return valueStr
            }
        }
        //whole
        else
        {
            if (valueStr.count >= 4 && !valueStr.contains("-") || valueStr.count >= 5 && valueStr.contains("-"))
            {
                return self.numberFormatter.string(from : NSDecimalNumber(string : valueStr))!
            }
            else
            {
                return valueStr
            }
        }
    }

}


