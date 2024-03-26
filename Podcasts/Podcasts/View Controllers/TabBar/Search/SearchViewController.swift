//
//  SearchViewController.swift
//  Podcasts
//
//  Created by mac on 25.10.2021.
//

import UIKit
import CoreData
import SwiftUI

typealias PlaylistByNewest  = [(key: String, podcasts: [Podcast])]
typealias PlayListByOldest = PlaylistByNewest
typealias PlayListByGenre = PlaylistByNewest


class SearchViewController: UIViewController, IHaveStoryBoardAndViewModel{
    
    struct Args {}
    typealias ViewModel = SearchViewModel
    
    func viewModelChanged(_ viewModel: SearchViewModel) {}
    func viewModelChanged() {
        updateUI()
    }
    
    private let container: IContainer
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var searchCollectionView: SearchCollectionView!
    @IBOutlet private weak var cancelLabel: UILabel!
    @IBOutlet private weak var searchSegmentalControl: UISegmentedControl!
    
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var emptyTableImageView: UIImageView!
    
    private var tableViewBottomConstraintConstant = CGFloat(0)
    private let refreshControl = UIRefreshControl()
    
    private var alert = Alert()
    
    //MARK: - Methods
    private var playerIsSHidden = true {
        didSet {
            tableViewBottomConstraintConstant = playerIsSHidden ? 0 : 50
            tableViewBottomConstraint?.constant = tableViewBottomConstraintConstant
        }
    }
    
    //MARK: - Public Methods
    func updateConstraintForTableView(playerIsPresent value: Bool) {
        playerIsSHidden = !value
    }
    
    private var isPodcast: Bool { searchSegmentalControl.selectedSegmentIndex == 0 }
    
    //MARK: init
    required init?(container: IContainer, args: (args: Args, coder: NSCoder)) {
        self.container = container
        super.init(coder: args.coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.isEmpty { searchBar.becomeFirstResponder() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGesture()
        tableViewBottomConstraint.constant = tableViewBottomConstraintConstant
        configureUI()
        updateUI()
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        cancelSearchAction()
        feedbackGenerator()
    }
    
    //MARK: - Actions
    func tapCell(atIndexPath indexPath: IndexPath) {
        viewModel.presentDetailVM(forIndexPath: indexPath)
    }
    
    @objc func cancelSearch(sender: UITapGestureRecognizer) {
        cancelSearchAction()
    }
    
    @objc func refresh() {
        viewModel.getPodcast()
        refreshControl.endRefreshing()
    }
    
    @objc func changeTypeOfSearch(sender: UISegmentedControl) {
        viewModel.setSelectedSegmentIndex(newValue: sender.selectedSegmentIndex)
    }
    
    @objc func handlerSwipe(sender: UISwipeGestureRecognizer) {
        var currentSegmentalIndex = viewModel.selectedSegmentIndex
        switch sender.direction {
        case .left:
            currentSegmentalIndex += 1
        case .right:
            currentSegmentalIndex -= 1
        default: break
        }
        viewModel.setSelectedSegmentIndex(newValue: currentSegmentalIndex )
    }
    
    func updateUI() {
        guard Thread.isMainThread else { fatalError()}
        if viewModel.isUpdating {
            view.showActivityIndicator()
        } else {
            view.hideActivityIndicator()
        }
        showEmptyImage()
        searchSegmentalControl.selectedSegmentIndex = viewModel.selectedSegmentIndex
        searchBar.text = viewModel.searchText
    }
    
    func configureUI() {
        observeViewModel()
        configureCancelLabel()
        configureSegmentalControl()
        configureAlert()
        addMyGestureRecognizer(view, type: .tap(), #selector(UIView.endEditing(_:)))
    }
}

//MARK: - Private configure UI Methods
extension SearchViewController {
    
    private func configureGesture() {
        //        addMyGestureRecognizer(self, type: .swipe(directions: [.left,.right]), #selector(handlerSwipe))
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    private func configureCancelLabel() {
        cancelLabel.addMyGestureRecognizer(self, type: .tap(), #selector(cancelSearch))
    }
    
    private func configureSegmentalControl() {
        searchSegmentalControl.addTarget(self, action: #selector(changeTypeOfSearch), for: .valueChanged)
    }
    
    private func configureAlert() {
        alert.delegate = self
    }
    
    private func cancelSearchAction() {
        viewModel.setSearchedText(text: "")
        viewModel.removeAll()
        showEmptyImage()
    }
    
    private func showEmptyImage() {
        let podcastsIsEmpty = viewModel.isEmpty
        
        searchCollectionView.isHidden = podcastsIsEmpty
        emptyTableImageView.isHidden = !podcastsIsEmpty
    }
    
    private func feedbackGenerator() {
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    
    private func observeViewModel() {
        
        viewModel.removeSection { [weak self] index in
            guard let self = self else { return }
            searchCollectionView.deleteSection(at: index)
        }
        
        viewModel.removeRow { [weak self] indexPath in
            guard let self = self else { return }
            searchCollectionView.deleteRow(at: indexPath)
        }
        
        
        viewModel.insertRow { [weak self] row, indexPath in
            guard let self = self else { return }
            searchCollectionView.insertRow(at: indexPath)
            //            searchCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
        
        viewModel.insertSection { [weak self] section, index in
            guard let self = self else { return }
            searchCollectionView.insertSection(section: section, at: index)
        }
        
        viewModel.moveSection { [weak self] index, newIndex in
            guard let self = self else { return }
            searchCollectionView.moveSection(index, toSection: newIndex)
        }
    }
}

//MARK: - Private methods
extension SearchViewController {

}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchCollectionView.setContentOffset(.zero, animated: true)
        guard let text = searchBar.text?.conform, !text.isEmpty else { showEmptyImage(); return }
        viewModel.getPodcast()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.setSearchedText(text: searchText)
    }
}

// MARK: - Alert Delegate
extension SearchViewController: AlertDelegate {
    
    func alertEndShow(_ alert: Alert) {
        dismiss(animated: true)
        searchBar.becomeFirstResponder()
    }
    
    func alertShouldShow(_ alert: Alert, alertController: UIAlertController) {
        present(alertController, animated: true)
    }
}

//MARK: - SearchCollectionViewDelegate
extension SearchViewController: SearchCollectionViewDelegate {
    
    func searchCollectionView(_ searchCollectionView: SearchCollectionView, didTapAtIndexPath indexPath: IndexPath) {
        tapCell(atIndexPath: indexPath)
    }
}

//MARK: - SearchCollectionViewDataSource
extension SearchViewController: SearchCollectionViewDataSource {
    
    func searchCollectionView(_ searchCollectionView: SearchCollectionView, sizeForSection section: Int) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func searchCollectionViewNumbersOfSections(_ searchCollectionView: SearchCollectionView) -> Int {
        return viewModel.numbersOfSections
    }
    
    func searchCollectionView(_ searchCollectionView: SearchCollectionView, nameOfSectionForIndex index: Int) -> String {
        return viewModel.getSectionForView(sectionIndex: index)
    }
    
    func searchCollectionView(_ searchCollectionView: SearchCollectionView, numbersOfRowsInSection index: Int) -> Int {
        return viewModel.numbersOfRowsInSection(section: index)
    }
    
    func searchCollectionView(_ searchCollectionView: SearchCollectionView, rowForIndexPath indexPath: IndexPath) -> SearchCollectionView.Row {
        let podcast = viewModel.getRowForView(forIndexPath: indexPath)
        let row = SearchCollectionView.Row(podcast: podcast)
        return row
    }
}
