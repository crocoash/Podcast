//
//  DetailViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit
import CoreData


class DetailViewController: UIViewController, IHaveStoryBoardAndViewModel {
    
    struct Args {}
    typealias ViewModel = DetailViewModel
    
    func viewModelChanged() {
        updateUI()
    }
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var episodeName        : UILabel!
    @IBOutlet private weak var artistName         : UILabel!
    @IBOutlet private weak var countryLabel       : UILabel!
    @IBOutlet private weak var durationLabel      : UILabel!
    @IBOutlet private weak var advisoryRatingLabel: UILabel!
    @IBOutlet private weak var dateLabel          : UILabel!
    @IBOutlet private weak var genresLabel        : UILabel!
    
    @IBOutlet private(set) weak var smallPlayerView: SmallPlayerView!
    
    @IBOutlet private weak var sortButton: UIButton!
    @IBOutlet private weak var descriptionTextView: UITextView!
    
    @IBOutlet private weak var episodeImage              : UIImageView!
    @IBOutlet private weak var backImageView             : UIImageView!
    @IBOutlet private weak var removeFromPlaylistBookmark: UIImageView!
    @IBOutlet private weak var addToPlaylistBookmark     : UIImageView!
    @IBOutlet private weak var playImageView             : UIImageView!
    
    @IBOutlet private weak var episodeTableView: EpisodeTableView!
    
    @IBOutlet private weak var heightTableViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomPlayerConstraint:NSLayoutConstraint!
    
    private var bigPlayerViewController: BigPlayerViewController?
    let container: IContainer
    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        smallPlayerView.isHidden = viewModel.playerIsHidden
        bottomPlayerConstraint.constant = viewModel.playerIsHidden ? 0 : 50
        view.layoutIfNeeded()
    }
    
    //MARK: Public Methods
    required init?(container: IContainer, args input: (args: Args, coder: NSCoder)) {
        
        self.container = container
        super.init(coder: input.coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Public Methods
    func scrollToCell() {
        guard let indexPath = viewModel.searchedIndexPath else { return }
        let positionOfCell = episodeTableView.getYPositionYFor(indexPath: indexPath)
        let positionOfTableView = episodeTableView.frame.origin.y
        let position = positionOfTableView + positionOfCell
        //TODO: - 12
        UIView.animate(withDuration: 12, animations: { [weak self] in
            guard let self = self else { return }
            scrollView.setContentOffset(CGPoint(x: .zero, y: position), animated: true)
        }) { [weak self] _ in
            guard let self = self else { return }
            viewModel.openCell(atIndexPath: indexPath)
        }
    }
    
    @IBAction private func backAction(_ sender: UITapGestureRecognizer) {
       dismiss(animated: true)
    }

    @IBAction private func shareButtonOnTouch(_ sender: UITapGestureRecognizer) {
        presentActivityViewController()
    }
    
    func configureUI() {}
    
    func updateUI() {
       
        episodeImage.image = nil
        configureEpisodeTableView()
        configureSortMenu()
        
        DataProvider.shared.downloadImage(string: viewModel.podcast.image600) { [weak self] image in
            self?.episodeImage.image = image
        }
        episodeName        .text = viewModel.podcast.trackName
        artistName         .text = viewModel.podcast.artistName ?? "Artist Name"
        genresLabel        .text = viewModel.podcast.genresString
        descriptionTextView.text = viewModel.podcast.descriptionMy
        countryLabel       .text = viewModel.podcast.country
        advisoryRatingLabel.text = viewModel.podcast.contentAdvisoryRating
        dateLabel          .text = viewModel.podcast.releaseDateInformation.formattedDate(dateFormat: "d MMM YYY")
        durationLabel      .text = viewModel.podcast.trackTimeMillis?.minute
        
        scrollToCell()
        presentSmallPlayer()
    }
}

//MARK: - Private Methods
extension DetailViewController {
    
    private func configureSortButton() {
        sortButton.setTitle(viewModel.activeSortType.rawValue, for: .normal)
    }
    
    private func configureSortMenu() {
        let title = viewModel.activeSortType.rawValue
        
        let childrens: [UIAction] = viewModel.sortMenu.map { sortType in
            let state: UIAction.State = viewModel.activeSortType == sortType ? .on : .off
            return UIAction(title: sortType.rawValue, state: state) { [weak self] action in
                guard let self = self else { return }
                viewModel.changeSortType(sortType: sortType)
                configureSortMenu()
            }
        }
        sortButton.menu = UIMenu(title: title, children: childrens)
        configureSortButton()
    }
    
    private func reloadTableViewHeightConstraint(newHeight: CGFloat) {
        heightTableViewConstraint.constant = newHeight
        view.layoutIfNeeded()
    }
    
    private func presentActivityViewController() {
        guard let trackViewUrl = viewModel.podcast.trackViewUrl,
              let image = episodeImage.image else { return }
        let text = "You should definitely listen to this!"
        
        let shareVC = UIActivityViewController(activityItems: [text, trackViewUrl, image], applicationActivities: [])
        
        if let popoverController = shareVC.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = view.bounds
        }
        present(shareVC, animated: true)
    }
    
    private func presentSmallPlayer() {
        if let smallPlayerViewModel = viewModel.smallPlayerViewModel, smallPlayerView.isHidden {
            smallPlayerView.viewModel = smallPlayerViewModel
            smallPlayerView.isHidden = false
        }
    }
    
    private func configureEpisodeTableView() {
        episodeTableView.translatesAutoresizingMaskIntoConstraints = false
        episodeTableView.viewModel = viewModel.episodeTableViewModel
        let height = episodeTableView.height
        reloadTableViewHeightConstraint(newHeight: height)
    }
}

//MARK: - EpisodeTableViewControllerMyDataSource
extension DetailViewController: EpisodeTableViewMyDataSource {
    
    func episodeTableViewDidChangeHeightTableView(_ episodeTableView: EpisodeTableView, height: CGFloat, withLastCell isLastCell: Bool) {
        if isLastCell {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self, let view = view else { return }
                reloadTableViewHeightConstraint(newHeight: height)
                let heightOfSmallPlayer = smallPlayerView.isHidden ? 0 : smallPlayerView.frame.height
                let y = episodeTableView.frame.maxY - (view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom) + heightOfSmallPlayer
                scrollView.setContentOffset(CGPoint(x: .zero, y: y), animated: true)
            }
        } else {
            UIView.animate(withDuration: 0.4) { [weak self] in
                guard let self = self else { return }
                reloadTableViewHeightConstraint(newHeight: height)
            }
        }
    }
}



////MARK: - FavouriteManagerDelegate
//extension DetailViewController: FavouriteManagerDelegate {
//    //MARK: - SmallPlayerViewDelegate
extension DetailViewController: SmallPlayerViewDelegate {
    
    func smallPlayerViewControllerSwipeOrTouch(_ smallPlayerView: SmallPlayerView) {
        viewModel.presentBigPlayer()
    }
}

//    func favouriteManager(_ favouriteManager: FavouriteManager, didRemove favourite: FavouritePodcast) {
//        view.addToast(title: "Remove from favourite" , smallPlayerView.isHidden ? .bottom : .bottomWithPlayer)
//    }
//    
//    func favouriteManager(_ favouriteManager: FavouriteManager, didAdd favourite: FavouritePodcast) {
//        view.addToast(title: "Add to favourite" , smallPlayerView.isHidden ? .bottom : .bottomWithPlayer)
//    }
//}
//

