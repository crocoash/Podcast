//
//  DetailViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit
import CoreData


class DetailViewController: UIViewController, IHaveStoryBoard, IHaveViewModel {
    
    
    
    typealias Args = ViewModel.Arguments
    typealias ViewModel = DetailViewControllerViewModel
    
    func viewModelChanged(_ viewModel: DetailViewControllerViewModel) {

    }
    
    func viewModelChanged() {
        setupView()
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
    
    private var player: Player
    private var downloadService: DownloadService
    private var bigPlayerViewController: BigPlayerViewController?
    private var likeManager: LikeManager
    private var favouriteManager: FavouriteManager
    let container: IContainer
    
    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
               
        if let track = player.currentTrack?.track {
            presentSmallPlayer(with: track)
        }
    }
    
    //MARK: Public Methods
    required init?(container: IContainer, args input: (args: Args, coder: NSCoder)) {
        
        self.player = container.resolve()
        self.downloadService = container.resolve()
        self.likeManager = container.resolve()
        self.favouriteManager = container.resolve()
        self.container = container
        
        super.init(coder: input.coder)
        
        self.favouriteManager.delegate = self
        let podcast = input.args.podcast
        let podcasts = input.args.podcasts
        let argVM = ViewModel.Arguments(podcast: input.args.podcast, podcasts: podcasts)
        self.viewModel = container.resolve(args: argVM)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Public Methods
    func scrollToCell(podcast: Podcast) {
        
//        guard let index = podcasts.firstIndex(matching: podcast) else { fatalError() }
//        let indexPath = IndexPath(row: index, section: 0)
//        let positionOfCell = episodeTableView.getYPositionYFor(indexPath: indexPath)
//        let positionOfTableView = episodeTableView.frame.origin.y
//        let position = positionOfTableView + positionOfCell
//        UIView.animate(withDuration: 12, animations: { [weak self] in
//            guard let self = self else { return }
//            scrollView.setContentOffset(CGPoint(x: .zero, y: position), animated: true)
//        }) { [weak self] _ in
//            guard let self = self else { return }
//            episodeTableView.openCell(at: indexPath)
//        }
    }
    @IBAction private func backAction(_ sender: UITapGestureRecognizer) {
       dismiss(animated: true)
    }

    @IBAction private func shareButtonOnTouch(_ sender: UITapGestureRecognizer) {
        presentActivityViewController()
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
    
    private func presentSmallPlayer(with viewModel: any OutputPlayerProtocol) {
        
        if smallPlayerView.isHidden {
            let model = SmallPlayerViewModel(viewModel)
            self.smallPlayerView.configure(with: model, player: player)
            smallPlayerView.isHidden = false
            bottomPlayerConstraint.constant = 50
            view.layoutIfNeeded()
        }
    }
    
    private func presentBigPlayer(with track: Track) {
        let argsVM: BigPlayerViewController.ViewModel.Arguments = BigPlayerViewController.ViewModel.Arguments.init(track: track)
        let args: BigPlayerViewController.Arguments = BigPlayerViewController.Arguments.init(delegate: self, modelInput: argsVM)
        let bigPlayerViewController: BigPlayerViewController = container.resolve(args: args)
        self.bigPlayerViewController = bigPlayerViewController
        bigPlayerViewController.modalPresentationStyle = .fullScreen
        self.present(bigPlayerViewController, animated: true)
    }
    
    private func configureEpisodeTableView() {
        episodeTableView.translatesAutoresizingMaskIntoConstraints = false
        episodeTableView.viewModel = viewModel.episodeTableViewModel
        let height = episodeTableView.height
        reloadTableViewHeightConstraint(newHeight: height)
    }
    
    private func setupView() {
       
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
    }
}


//MARK: - SmallPlayerViewControllerDelegate
extension DetailViewController: SmallPlayerViewControllerDelegate {
    
    func smallPlayerViewControllerSwipeOrTouch(_ smallPlayerViewController: SmallPlayerView) {
        guard let track = player.currentTrack?.track else { return }
        presentBigPlayer(with: track)
    }
}

//MARK: - BigPlayerViewControllerDelegate
extension DetailViewController: BigPlayerViewControllerDelegate {
    
    func bigPlayerViewControllerDidTouchPodcastNameLabel(_ bigPlayerViewController: BigPlayerViewController, entity: NSManagedObject) {
        bigPlayerViewController.dismiss(animated: true, completion: { [weak self] in
            guard let self = self,
                  let podcast = entity as? Podcast else { return }
            
            scrollToCell(podcast: podcast)
        })
    }
}

//MARK: - PlayerDelegate
extension DetailViewController: PlayerDelegate {
    
    func playerDidEndPlay(_ player: Player, with track: any OutputPlayerProtocol) {}
    
    func playerStartLoading(_ player: Player, with track: any OutputPlayerProtocol) {
        presentSmallPlayer(with: track)
    }
    
    func playerDidEndLoading(_ player: Player, with track: any OutputPlayerProtocol) {}
    
    func playerUpdatePlayingInformation(_ player: Player, with track: any OutputPlayerProtocol) {}
    
    func playerStateDidChanged(_ player: Player, with track: any OutputPlayerProtocol) {}
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

//MARK: - FavouriteManagerDelegate
extension DetailViewController: FavouriteManagerDelegate {
    
    func favouriteManager(_ favouriteManager: FavouriteManager, didRemove favourite: FavouritePodcast) {
        view.addToast(title: "Remove from favourite" , smallPlayerView.isHidden ? .bottom : .bottomWithPlayer)
    }
    
    func favouriteManager(_ favouriteManager: FavouriteManager, didAdd favourite: FavouritePodcast) {
        view.addToast(title: "Add to favourite" , smallPlayerView.isHidden ? .bottom : .bottomWithPlayer)
    }
}


