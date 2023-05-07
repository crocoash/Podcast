//
//  TableView.swift
//  Podcasts
//
//  Created by Anton on 28.04.2023.
//

import UIKit

protocol EpisodeTableViewDelegate: AnyObject {
    func episodeTableViewPlayButtonDidTouchFor(_ episodeTableView: EpisodeTableView, podcast: Podcast, at moment: Double?, playlist: [Podcast])
    func episodeTableViewStopButtonDidTouchFor(_ episodeTableView: EpisodeTableView)
    func episodeTableView(_ episodeTableView: EpisodeTableView, addToFavoriteButtonDidTouchFor podcast: Podcast)
    func episodeTableView(_ episodeTableView: EpisodeTableView, removeFromFavoriteButtonDidTouchFor selectedPodcast: Podcast)
    func episodeTableViewDidSelectDownLoadImage(_ episodeTableView: EpisodeTableView, entity: DownloadServiceProtocol, completion: @escaping () -> Void)
    func episodeTableViewDidSelectCell(_ episodeTableView: EpisodeTableView, at indexPath: IndexPath)
}

protocol EpisodeTableViewMyDataSource: AnyObject {
    func episodeTableViewDidChangeHeightTableView(_ episodeTableView: EpisodeTableView, height: CGFloat)
}

protocol EpisodeTableViewPlayableProtocol: PodcastCellPlayableProtocol {
    var id: NSNumber? { get }
}

@IBDesignable
class EpisodeTableView: UITableView {
   
    private let defaultRowHeight: CGFloat = 100
    private var sumOfHeightsOfAllHeaders :CGFloat = 0
    private var paddingBetweenSections: CGFloat = 0
    
    weak var myDelegate: EpisodeTableViewDelegate?
    weak var myDataSource: EpisodeTableViewMyDataSource?
    
    private var selectedCellAndHisHeight = [IndexPath : CGFloat]()

    lazy private var typeOfSort: TypeSortOfTableView = .byGenre
    
    private var playlistByGenre = PlayListByGenre()
    private var playlistByNewest = PlaylistByNewest()
    private var playlistByOldest = PlayListByOldest()
    
    enum TypeSortOfTableView {
        case byNewest
        case byOldest
        case byGenre
    }
    
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
    
    private var playlist: [Podcast]! {
        didSet {
            playlistByGenre = playlist.sortPodcastsByGenre
            playlistByNewest = playlist.sortPodcastsByNewest
            playlistByOldest = playlist.sortPodcastsByOldest
        }
    }
    
    private var headers = [UILabel]()
   
    //MARK: - PublicMethods
    func configureEpisodeTableView<T: EpisodeTableViewDelegate & EpisodeTableViewMyDataSource>(_ vc: T, with playlist: [Podcast]) {
        self.myDelegate = vc
        self.myDataSource = vc
        
        self.playlist = playlist
        configureHeadersForSectionsAndCalculateHeightsOfAllHeaders()
        reloadData()
        reloadTableViewHeight()
    }
    
    //MARK: Downloading
    func endDownloading(podcast: Podcast) {
        guard let indexPath = currentPlaylist.getIndexPath(for: podcast).first else { return }
        if let cell = cellForRow(at: indexPath) as? PodcastCell {
            cell.endDownloading()
        }
    }
        
    func reloadCell(for id: NSNumber?) {
        let indexPath = currentPlaylist.getIndexPath(for: id)
        reloadRows(at: indexPath, with: .none)
    }
    
    private func setHeightOfEpisodeTableView() -> CGFloat {
         return currentPlaylist.countOfValues.cgFloat * defaultRowHeight + sumOfHeightsOfAllHeaders
    }
    
    func getCell(id: NSNumber?) -> PodcastCell? {
        guard let indexPath = currentPlaylist.getIndexPath(for: id).first else { return nil }
        if let cell = cellForRow(at: indexPath) as? PodcastCell {
            return cell
        }
        return nil
    }
    
    func changeTypeOfSort(_ typeOfSort: TypeSortOfTableView) {
        self.typeOfSort = typeOfSort
        configureHeadersForSectionsAndCalculateHeightsOfAllHeaders()
        reloadTableViewHeight()
        reloadData()
    }
    
    private func reloadTableViewHeight() {
        let allHeight = selectedCellAndHisHeight.arrayOfValues.reduce(into: 0) { $0 += $1 - defaultRowHeight }
        let heightOfTableView = currentPlaylist.countOfValues.cgFloat * defaultRowHeight + allHeight + sumOfHeightsOfAllHeaders
        myDataSource?.episodeTableViewDidChangeHeightTableView(self, height: heightOfTableView)
    }
    
    func updateDownloadInformation(progress: Float, totalSize: String, for podcast: Podcast) {
        guard let indexPath = currentPlaylist.getIndexPath(for: podcast).first,
              let podcastCell = cellForRow(at: indexPath) as? PodcastCell
        else { return }
        
        podcastCell.updateDownloadInformation(progress: progress, totalSize: totalSize)
    }
    
    ///BigPlayer
    func positionYOfCell(id: NSNumber?) -> CGFloat {
        guard let cell = getCell(id: id) ,let indexPath = indexPath(for: cell) else { return 0 }
        return rectForRow(at: indexPath).origin.y
    }
    
    //MARK: - ViewMethods
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addObserverPlayerEventNotification()
        
        delegate = self
        dataSource = self
        
        if #available(iOS 15.0, *) {
            paddingBetweenSections = 20
            sectionHeaderTopPadding = paddingBetweenSections
        }
    }
    
    deinit {
        removeObserverEventNotification()
    }
}

//MARK: - Private Methods
extension EpisodeTableView {
    
    private func configureHeadersForSectionsAndCalculateHeightsOfAllHeaders () {
        headers.removeAll()
        sumOfHeightsOfAllHeaders = 0
        
        for item in currentPlaylist {
            let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: frame.width, height: .zero)))
            label.numberOfLines = 0
            label.text = item.key
            let heightOfHeader = label.font.lineHeight * label.maxNumberOfLines.cgFloat + paddingBetweenSections
            
            label.frame.size = CGSize(width: label.frame.width, height: heightOfHeader)
            sumOfHeightsOfAllHeaders += heightOfHeader
            headers.append(label)
        }
    }
   
    private func getPodcast(_ cell: UITableViewCell) -> Podcast? {
        guard let indexPath = indexPath(for: cell) else { return nil }
        return currentPlaylist[indexPath.section].podcasts[indexPath.row]
    }
}

//MARK: - EpisodeTableView
extension EpisodeTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentPlaylist.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPlaylist[section].podcasts.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headers[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
        let podcast = currentPlaylist[indexPath.section].podcasts[indexPath.row]
        cell.configureCell(self, with: podcast)
        return cell
    }
}

//MARK: - UITableViewDelegate
extension EpisodeTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedCellAndHisHeight[indexPath] != nil {
            if let cell = tableView.cellForRow(at: indexPath) as? PodcastCell, cell.podcastDescription.maxNumberOfLines > 3 {
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
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /// write value for calculate height of tableview
        let offset = tableView.rectForRow(at: indexPath).height
        if selectedCellAndHisHeight[indexPath] != nil {
            selectedCellAndHisHeight[indexPath] = offset
        }
    }
}

//MARK: - PodcastCellDelegate
extension EpisodeTableView: PodcastCellDelegate {
    
    func podcastCellDidTouchPlayButton(_ podcastCell: PodcastCell) {
        guard let podcast = getPodcast(podcastCell) else { return }
        myDelegate?.episodeTableViewPlayButtonDidTouchFor(self, podcast: podcast, at: Double(podcast.currentTime ?? 0), playlist: currentPlaylist.flatMap { $0.podcasts })
    }
    
    func podcastCellDidTouchStopButton(_ podcastCell: PodcastCell) {
        myDelegate?.episodeTableViewStopButtonDidTouchFor(self)
    }
    
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell) {
        guard let podcast = getPodcast(podcastCell) else { return }
        myDelegate?.episodeTableView(self, addToFavoriteButtonDidTouchFor: podcast)
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell) {
        guard let podcast = getPodcast(podcastCell) else { return }
        
        myDelegate?.episodeTableViewDidSelectDownLoadImage(self, entity: podcast) {
            
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

//MARK: - PlayerEventNotification
extension EpisodeTableView: PlayerEventNotification {
    
    func addObserverPlayerEventNotification() {
        Player.addObserverPlayerPlayerEventNotification(for: self)
    }
    
    func removeObserverEventNotification() {
        Player.removeObserverEventNotification(for: self)
    }
    
    func playerDidEndPlay(notification: NSNotification) {
        guard let player = notification.object as? EpisodeTableViewPlayableProtocol else { return }
        let id = player.id
        reloadCell(for: id)
    }
    
    func playerStartLoading(notification: NSNotification) {
        guard let player = notification.object as? EpisodeTableViewPlayableProtocol else { return }
        let id = player.id
        let cell = getCell(id: id)
        cell?.playerIsGoingPlay(player: player)
    }
    
    func playerDidEndLoading(notification: NSNotification) {
        guard let player = notification.object as? EpisodeTableViewPlayableProtocol else { return }
        let id = player.id
        let cell = getCell(id: id)
        cell?.playerIsEndLoading(player: player)
    }
    
    func playerUpdatePlayingInformation(notification: NSNotification) {
        guard let player = notification.object as? EpisodeTableViewPlayableProtocol else { return }
        let id = player.id
        let cell = getCell(id: id)
        cell?.updateListeningProgressView(player: player)
    }
    
    func playerStateDidChanged(notification: NSNotification) {
        guard let player = notification.object as? DetailPlayableProtocol else { return }
        let id = player.id
        let cell = getCell(id: id)
        cell?.updatePlayStopButton(player: player)
    }
}
