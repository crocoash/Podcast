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
    
    @IBOutlet weak var item1: UICommand!
    
    
    @IBOutlet private weak var episodeTableView: UITableView!
    @IBOutlet private weak var heightTableViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomPlayerConstraint:    NSLayoutConstraint!
    
    //MARK: Variables
    private(set) var podcast : Podcast? {
        didSet {
            if let _ = oldValue {
                episodeTableView.reloadData()
                setupView()
            }
        }
    }
    
    private let defaultRowHeight: CGFloat = 100
    private var sumOfHeightsOfAllHeaders :CGFloat = 0
    private let paddingBetweenSections: CGFloat = 20
    
    private var playlistByGenre = PlayListByGenre()
    private var playlistByNewest = PlaylistByNewest()
    private var playlistByOldest = PlayListByOldest()
    private var currentPlaylist: [(key: String, podcasts: [Podcast])] {
        switch typeOfSort {
        case .byGenre:
            return playlistByGenre
        case .byNewest:
            return playlistByNewest
        case .byOldest:
            return playlistByOldest
        }
    }
                                   
    private var headers = [UILabel]()
    weak var delegate: DetailViewControllerDelegate?
    
    private var selectedCellAndHisHeight = [IndexPath : CGFloat]()
        
    private enum TypeSortOfTableView {
        case byNewest
        case byOldest
        case byGenre
    }
    
    private var typeOfSort: TypeSortOfTableView = .byGenre {
        didSet {
            configureHeadersForSectionsAndCalculateHeightsOfAllHeaders()
            setHeightOfEpisodeTableView()
            episodeTableView.reloadData()
        }
    }
    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGestures()
        setupView()
        smallPlayerView.delegate = self
    }
    
    //MARK: Public Methods
    func setUp(podcast: Podcast, playlist: [Podcast]) {
        playlistByGenre = playlist.sortPodcastsByGenre
        playlistByNewest = playlist.sortPodcastsByNewest
        playlistByOldest = playlist.sortPodcastsByOldest
        self.podcast = podcast
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
        
        configureHeadersForSectionsAndCalculateHeightsOfAllHeaders()
        setHeightOfEpisodeTableView()
    
        if #available(iOS 15.0, *) {
            episodeTableView.sectionHeaderTopPadding = paddingBetweenSections
        }
        
        episodeName        .text = podcast?.trackName
        artistName         .text = podcast?.artistName
        genresLabel        .text = podcast?.genresString
        descriptionTextView.text = currentPlaylist[0].podcasts.first?.descriptionMy
        countryLabel       .text = podcast?.country
        advisoryRatingLabel.text = podcast?.contentAdvisoryRating
        dateLabel          .text = podcast?.releaseDateInformation?.formattedDate(dateFormat: "d MMM YYY")
        durationLabel      .text = podcast?.trackTimeMillis?.minute
    }
    
    ///BigPlayer
    func scrollToCell(id: NSNumber?) {
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
        guard let indexPath = currentPlaylist.getIndexPath(for: podcast).first,
              let podcastCell = episodeTableView?.cellForRow(at: indexPath) as? PodcastCell
        else { return }
        
        podcastCell.updateDownloadInformation(progress: progress, totalSize: totalSize)
    }
    
    func endDownloading(podcast: Podcast) {
        guard let indexPath = currentPlaylist.getIndexPath(for: podcast).first else { return }
        if let cell = episodeTableView.cellForRow(at: indexPath) as? PodcastCell {
            cell.endDownloading()
        }
    }
    
    //MARK: - Actions
    @objc private func backAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction private func refreshByGenre(_ sender: UICommand) {
        typeOfSort = .byGenre
    }
    
    @IBAction private func refreshByNewest(_ sender: UICommand) {
        typeOfSort = .byNewest
    }
    
    @IBAction private func refreshByOldest(_ sender: UICommand) {
        typeOfSort = .byOldest
    }
}

//MARK: - Private Methods
extension DetailViewController {
    
    private func getCell(id: NSNumber?) -> PodcastCell? {
        guard let indexPath = currentPlaylist.getIndexPath(for: id).first else { return nil }
        if let cell = episodeTableView.cellForRow(at: indexPath) as? PodcastCell {
            return cell
        }
        return nil
    }
    
    private func configureGestures() {
        backImageView.addMyGestureRecognizer(self, type: .tap(),#selector(backAction))
        addMyGestureRecognizer(self, type: .screenEdgePanGestureRecognizer(directions: [.left]), #selector(backAction))
    }
    
    private func getPodcast(_ cell: UITableViewCell) -> Podcast? {
        guard let indexPath = episodeTableView.indexPath(for: cell) else { return nil }
        return currentPlaylist[indexPath.section].podcasts[indexPath.row]
    }
    
    private func reloadCellHeightIsChange(for indexPath: IndexPath) {
        episodeTableView.reloadRows(at: [indexPath], with: .automatic)
        reloadTableViewHeightConstraint()
    }
    
    private func reloadTableViewHeightConstraint() {
        let allHeight = selectedCellAndHisHeight.arrayOfValues
        let offSet = allHeight.reduce(into: .zero) { $0 += $1 - defaultRowHeight }
        let heightOfTableView = currentPlaylist.countOfValues.cgFloat * defaultRowHeight + offSet + sumOfHeightsOfAllHeaders
        
        heightTableViewConstraint.constant = heightOfTableView
    }

    private func reloadCell(for id: NSNumber?) {
        let indexPath = currentPlaylist.getIndexPath(for: id)
        episodeTableView?.reloadRows(at: indexPath, with: .none)
    }
    
    private var getCountOfSections: Int {
        return currentPlaylist.count
    }
    
    private func getHeader(for section: Int) -> UILabel {
       return headers[section]
    }
    
    private func getCountOfRowsInSection(section: Int) -> Int {
        return currentPlaylist[section].podcasts.count
    }
    
    private func configureHeadersForSectionsAndCalculateHeightsOfAllHeaders () {
        headers.removeAll()
        sumOfHeightsOfAllHeaders = 0
     
        for item in currentPlaylist {
            let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: episodeTableView.frame.width, height: .zero)))
            label.numberOfLines = 0
            label.text = item.key
            let heightOfHeader = label.font.lineHeight * label.maxNumberOfLines.cgFloat + paddingBetweenSections

            label.frame.size = CGSize(width: label.frame.width, height: heightOfHeader)
            sumOfHeightsOfAllHeaders += heightOfHeader
            headers.append(label)
        }
    }
    
    private func setHeightOfEpisodeTableView() {
        heightTableViewConstraint.constant = currentPlaylist.countOfValues.cgFloat * defaultRowHeight + sumOfHeightsOfAllHeaders + 20
        episodeTableView.layoutIfNeeded()
    }
}

//MARK: - UITableViewDataSource
extension DetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return getCountOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCountOfRowsInSection(section: section)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return getHeader(for: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = episodeTableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
        let podcast = currentPlaylist[indexPath.section].podcasts[indexPath.row]
        cell.configureCell(self, with: podcast)
        return cell
    }

}

//MARK: - UITableViewDelegate
extension DetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedCellAndHisHeight[indexPath] != nil {
            if let cell = episodeTableView.cellForRow(at: indexPath) as? PodcastCell, cell.podcastDescription.maxNumberOfLines > 3 {
                return UITableView.automaticDimension
            }
        }
        return defaultRowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// check if the cell all ready selected
        if selectedCellAndHisHeight[indexPath] == nil {
            selectedCellAndHisHeight[indexPath] = 0 // default value
        } else {
            selectedCellAndHisHeight[indexPath] = nil
        }
        reloadCellHeightIsChange(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /// write value for calculate height of tableview
        let offset = tableView.rectForRow(at: indexPath).height
        if selectedCellAndHisHeight[indexPath] != nil {
            selectedCellAndHisHeight[indexPath] = offset
            reloadTableViewHeightConstraint()
        }
    }
}

//MARK: - PodcastCellDelegate
extension DetailViewController: PodcastCellDelegate {
    
    func podcastCellDidTouchPlayButton(_ podcastCell: PodcastCell) {
        guard let podcast = getPodcast(podcastCell) else { return }
        delegate?.detailViewControllerPlayButtonDidTouchFor(self, podcast: podcast, at: Double(podcast.currentTime ?? 0), playlist: currentPlaylist.flatMap { $0.podcasts })
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

//MARK: - SmallPlayerViewControllerDelegate
extension DetailViewController: SmallPlayerViewControllerDelegate {
    
    func smallPlayerViewControllerSwipeOrTouch(_ smallPlayerViewController: SmallPlayerViewController) {
        delegate?.detailViewControllerDidSwipeOnPlayer(self)
    }
    
    func smallPlayerViewControllerDidTouchPlayStopButton(_ smallPlayerViewController: SmallPlayerViewController) {
        delegate?.detailViewControllerPlayStopButtonDidTouchInSmallPlayer(self)
    }
}
