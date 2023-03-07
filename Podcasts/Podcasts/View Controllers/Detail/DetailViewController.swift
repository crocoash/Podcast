//
//  DetailViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit

protocol DetailViewControllerDelegate: AnyObject {
    func detailViewControllerPlayButtonDidTouchFor(_ detailViewController: DetailViewController, podcast: Podcast, at moment: Double?, playlist: [Podcast])
    func detailViewControllerPlayStopButtonDidTouchInSmallPlayer(_ detailViewController: DetailViewController)
    func detailViewControllerDidSwipeOnPlayer(_ detailViewController: DetailViewController)
    func detailViewControllerStopButtonDidTouchFor(_ detailViewController: DetailViewController, podcast: Podcast)
    func detailViewController(_ detailViewController: DetailViewController, addToFavoriteButtonDidTouchFor podcast: Podcast)
    func detailViewController(_ detailViewController: DetailViewController, removeFromFavoriteButtonDidTouchFor selectedPodcast: Podcast)
    func detailViewControllerDidSelectDownLoadImage(_ detailViewController: DetailViewController, podcast: Podcast, completion: @escaping () -> Void)
}

protocol DetailPlayableProtocol: PodcastCellPlayableProtocol, SmallPlayerPlayableProtocol {
    var id: NSNumber? { get }
    var isPlaying: Bool { get }
    var progress: Double? { get }
}

class DetailViewController: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var episodeName        : UILabel!
    @IBOutlet private weak var artistName         : UILabel!
    @IBOutlet private weak var countryLabel       : UILabel!
    @IBOutlet private weak var durationLabel      : UILabel!
    @IBOutlet private weak var advisoryRatingLabel: UILabel!
    @IBOutlet private weak var dateLabel          : UILabel!
    @IBOutlet private weak var genresLabel        : UILabel!
    
    @IBOutlet private(set) weak var smallPlayerView: SmallPlayerViewController!
    
    @IBOutlet private weak var descriptionTextView: UITextView!

    @IBOutlet private weak var episodeImage              : UIImageView!
    @IBOutlet private weak var backImageView             : UIImageView!
    @IBOutlet private weak var removeFromPlaylistBookmark: UIImageView!
    @IBOutlet private weak var addToPlaylistBookmark     : UIImageView!
    @IBOutlet private weak var playImageView             : UIImageView!
    
    @IBOutlet private weak var sortButton: UIButton!
    
    @IBOutlet private weak var episodeTableView: UITableView!

    @IBOutlet private weak var heightTableViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomPlayerConstraint:    NSLayoutConstraint!
    
    //MARK: Variables
    private(set) var podcast : Podcast? {
        didSet {
            if oldValue != nil {
                episodeTableView.reloadData(); setupView()
            }
        }
    }
    
    private let heightCell: CGFloat = 100
    
    private var selectedCell: [IndexPath: CGFloat] = [:] {
        didSet {
            let allIndexPath = Array(selectedCell.keys)
            episodeTableView.reloadRows(at: allIndexPath, with: .automatic)
        }
    }
    
    private func reloadTableView() {
        let allHeight = Array(selectedCell.values)
        let offSet = allHeight.reduce(into: CGFloat.zero) { $0 += $1 - 100 }
        let heightOfTableView = CGFloat(playlist.count) * heightCell + offSet
        heightTableViewConstraint.constant = heightOfTableView
        episodeTableView.layoutIfNeeded()
    }
    
    private(set) var playlist: [Podcast] = []
    weak var delegate: DetailViewControllerDelegate?

    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGestures()
        setupView()
        smallPlayerView.delegate = self
    }
    
    //MARK: Public Methods
    func setUp(podcast: Podcast, playlist: [Podcast]) {
        self.playlist = playlist.sorted { $0.releaseDateInformation! > $1.releaseDateInformation! }
        self.podcast = podcast
    }
    
    //TODO: remove this
    private func createSortChildMenu(genre: Genre) -> UIAction {
        let popUpButtonClosure = { (action: UIAction) in
            print("Pop-up action")
        }
          
        return UIAction(title: genre.name ?? "" , handler: popUpButtonClosure)
    }
    
    func updateConstraintForTableView(playerIsPresent: Bool) {
        smallPlayerView.isHidden = !playerIsPresent
        bottomPlayerConstraint.constant = playerIsPresent ? 50 : 0
    }
    
    func setupView() {
        episodeImage.image = nil
        DataProvider.shared.downloadImage(string: podcast?.image600) { [weak self] image in
            self?.episodeImage.image = image
        }
        heightTableViewConstraint.constant = CGFloat(playlist.count) * heightCell
        updateBookMark()
        episodeName.text = podcast?.trackName
        artistName.text = podcast?.artistName
        genresLabel.text = podcast?.genresString
        descriptionTextView.text = playlist[0].descriptionMy
        countryLabel.text = podcast?.country
        advisoryRatingLabel.text = podcast?.contentAdvisoryRating
        dateLabel.text = podcast?.releaseDateInformation?.formattedDate(dateFormat: "d MMM YYY")
        
///        DateFormatter().date(from: <#T##String#>)
        durationLabel.text = podcast?.trackTimeMillis?.minute
    }
    
    ///BigPlayer
    func setOffsetForBigPlayer(id: NSNumber?) {
        guard let cell = getCell(id: id) ,let indexPath = episodeTableView.indexPath(for: cell) else { return }
        let yPositionCell = episodeTableView.rectForRow(at: indexPath).origin.y
        let y = episodeTableView.frame.origin.y
        scrollView.setContentOffset(CGPoint(x: 0, y: y + yPositionCell), animated: true)
        cell.setHighlighted(true, animated: true)
        
    }
    
    ///DetailPlayableProtocol
    func playerEndPlay(player: DetailPlayableProtocol) {
        let id = player.id
        reloadCell(for: id)
        
    }
    
    func playerIsGoingPlay(player: DetailPlayableProtocol) {
        let id = player.id
        let cell = getCell(id: id)
        cell?.playerIsGoingPlay(player: player)
        smallPlayerView.playerIsGoingPlay(player: player)
    }
    
    func playerIsEndLoading(player: DetailPlayableProtocol) {
        let id = player.id
        let cell = getCell(id: id)
        cell?.playerIsEndLoading(player: player)
        smallPlayerView.playerIsEndLoading(player: player)
    }
    
    func updateProgressView(player: DetailPlayableProtocol) {
        let id = player.id
        let cell = getCell(id: id)
        cell?.updateListeningProgressView(player: player)
        smallPlayerView.updateProgressView(player: player)
    }
    
    func updatePlayStopButton(player: DetailPlayableProtocol) {
        let id = player.id
        let cell = getCell(id: id)
        cell?.updatePlayStopButton(player: player)
        smallPlayerView.setPlayStopButton(player: player)
    }
    
    //MARK: Downloading
    func updateDownloadInformation(progress: Float, totalSize: String, for podcast: Podcast) {
        guard let index = playlist.firstIndex(matching: podcast),
              let podcastCell = episodeTableView?.cellForRow(at: IndexPath(row: index, section: 0)) as? PodcastCell
        else { return }
        
        podcastCell.updateDownloadInformation(progress: progress, totalSize: totalSize)
    }
    
    func endDownloading(podcast: Podcast) {
        guard let index = playlist.firstIndex(matching: podcast) else { return }
        if let cell = episodeTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? PodcastCell {
            cell.endDownloading()
        }
    }
    
    //TODO: Remove this
    func reloadCell(for id: NSNumber?) {
        guard let index = playlist.firstIndex(where: { $0.id == id }) else { return }
        episodeTableView?.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
    
    //MARK: Actions
    @objc private func addBookmarkOnTouchUpInside(_ sender: UIButton) {
//        delegate?.detailViewController(self, addToFavoriteButtonDidTouchFor: podcast)
//        updateBookMark()
    }
    
    @objc private func removeBookmarkOnTouchUpInside(_ sender: UIButton) {
//        let podcast = Podcast(podcast: podcast, viewContext: nil)
//        delegate?.detailViewController(self, removeFromFavoriteButtonDidTouchFor: self.podcast)
//        self.podcast = podcast
//        updateBookMark()
    }
    
    @objc private func backAction(_ sender: Any) {
        dismiss(animated: true)
    }
}

//MARK: - Private Methods
extension DetailViewController {
    
    private func getCell(id: NSNumber?) -> PodcastCell? {
        if let index = playlist.firstIndex(where: { $0.id == id }) {
            if let cell = episodeTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? PodcastCell {
                return cell
            }
        }
        return nil
    }
    
    private func configureGestures() {
        backImageView             .addMyGestureRecognizer(self, type: .tap(),                                               #selector(backAction))
        removeFromPlaylistBookmark.addMyGestureRecognizer(self, type: .tap(),                                               #selector(removeBookmarkOnTouchUpInside))
        addToPlaylistBookmark     .addMyGestureRecognizer(self, type: .tap(),                                               #selector(addBookmarkOnTouchUpInside))
                                   addMyGestureRecognizer(self, type: .screenEdgePanGestureRecognizer(directions: [.left]), #selector(backAction))
    }
    
    private func updateBookMark() {
//        guard let isFavorite = podcast?.isFavorite else { return }
//        addToPlaylistBookmark.isHidden = isFavorite
//        removeFromPlaylistBookmark.isHidden = !isFavorite
    }
    
    private func getPodcast(_ cell: UITableViewCell) -> Podcast? {
        guard let index = episodeTableView.indexPath(for: cell)?.row else { return nil }
        return playlist[index]
    }
}

//MARK: - UITableViewDataSource
extension DetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = episodeTableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
        let podcast = playlist[indexPath.row]
        cell.configureCell(self, with: podcast)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let offset = tableView.rectForRow(at: indexPath).height
        if selectedCell[indexPath] != nil {
            selectedCell[indexPath] = offset
            reloadTableView()
        }
    }
}

extension DetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedCell[indexPath] == nil {
            selectedCell[indexPath] = 0
        } else {
            selectedCell[indexPath] = nil
            reloadTableView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedCell[indexPath] != nil {
            return UITableView.automaticDimension
        }
        return 100
    }
}

//MARK: - PodcastCellDelegate
extension DetailViewController: PodcastCellDelegate {
    
    func podcastCellDidTouchPlayButton(_ podcastCell: PodcastCell) {
        guard let podcast = getPodcast(podcastCell) else { return }
        delegate?.detailViewControllerPlayButtonDidTouchFor(self, podcast: podcast, at: Double(podcast.currentTime ?? 0), playlist: playlist)
    }
    
    func podcastCellDidTouchStopButton(_ podcastCell: PodcastCell) {
        guard let podcast = getPodcast(podcastCell) else { return }
        delegate?.detailViewControllerStopButtonDidTouchFor(self, podcast: podcast)
    }
    
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell) {
        guard let podcast = getPodcast(podcastCell) else { return }
        delegate?.detailViewController(self, addToFavoriteButtonDidTouchFor: podcast)
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell) {
        guard let podcast = getPodcast(podcastCell) else { return }
        
        delegate?.detailViewControllerDidSelectDownLoadImage(self, podcast: podcast) {
            
            switch podcast.stateOfDownload {
                
            case .isDownload:
                podcastCell.endDownloading()
                
            case .notDownloaded:
                podcastCell.removePodcastFromDownloads()
                
            case .isDownloading:
                podcastCell.startDownloading()
            }
        }
    }
}

extension DetailViewController: SmallPlayerViewControllerDelegate {
    
    func smallPlayerViewControllerSwipeOrTouch(_ smallPlayerViewController: SmallPlayerViewController) {
        delegate?.detailViewControllerDidSwipeOnPlayer(self)
    }
    
    func smallPlayerViewControllerDidTouchPlayStopButton(_ smallPlayerViewController: SmallPlayerViewController) {
        delegate?.detailViewControllerPlayStopButtonDidTouchInSmallPlayer(self)
    }
}

extension NSNumber {
    var minute: String {
        String((self.intValue / 1000) / 60) + " min"
    }
}
