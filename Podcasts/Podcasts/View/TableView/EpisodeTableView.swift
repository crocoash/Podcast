//
//  TableView.swift
//  Podcasts
//
//  Created by Anton on 28.04.2023.
//

import UIKit

protocol EpisodeTableViewDelegate: AnyObject {
    func episodeTableViewPlayButtonDidTouchFor(_ episodeTableView: EpisodeTableView, podcast: Podcast, playlist: [Podcast])
    func episodeTableViewStopButtonDidTouchFor(_ episodeTableView: EpisodeTableView)
    func episodeTableView(_ episodeTableView: EpisodeTableView, addToFavoriteButtonDidTouchFor podcast: Podcast)
    func episodeTableView(_ episodeTableView: EpisodeTableView, removeFromFavoriteButtonDidTouchFor selectedPodcast: Podcast)
    func episodeTableViewDidSelectDownLoadImage(_ episodeTableView: EpisodeTableView, entity: DownloadProtocol)
}

protocol EpisodeTableViewMyDataSource: AnyObject {
    func episodeTableViewDidChangeHeightTableView(_ episodeTableView: EpisodeTableView, height: CGFloat, withLastCell: Bool)
}

protocol EpisodeTableViewPlayableProtocol: PodcastCellPlayableProtocol {
    var identifier: String { get }
}

class EpisodeTableView: UITableView {
   
    lazy private var defaultRowHeight = frame.width / 3.5
    private var sumOfHeightsOfAllHeaders = CGFloat.zero
    private var paddingBetweenSections = CGFloat(20)
    
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
   
    func reloadCell(for id: String) {
        let indexPath = currentPlaylist.getIndexPaths(for: id)
        reloadRows(at: indexPath, with: .none)
    }
    
    func getCell(id: String) -> PodcastCell? {
        guard let indexPath = currentPlaylist.getIndexPaths(for: id).first else { return nil }
        if let cell = cellForRow(at: indexPath) as? PodcastCell {
            return cell
        }
        return nil
    }
    
    func changeTypeOfSort(_ typeOfSort: TypeSortOfTableView) {
        self.typeOfSort = typeOfSort
        configureHeadersForSectionsAndCalculateHeightsOfAllHeaders()
        reloadData()
        reloadTableViewHeight()
    }
    
    ///BigPlayer
    func positionYOfCell(id: String) -> CGFloat {
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
            sectionHeaderTopPadding = paddingBetweenSections
        }
    }
    
    deinit {
        removeObserverEventNotification()
    }
    
    //MARK: Actions
    @objc func tapCell(sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? PodcastCell,
              cell.moreThanThreeLines,
              let indexPath = indexPath(for: cell) else { return }
        
        if selectedCellAndHisHeight[indexPath] == nil {
            selectedCellAndHisHeight[indexPath] = 0 // default value
        } else {
            selectedCellAndHisHeight[indexPath] = nil
        }
        
        UIView.animate(withDuration: 0.4) {
            self.beginUpdates()
            self.endUpdates()
            if self.selectedCellAndHisHeight[indexPath] != nil {
                let offset = self.rectForRow(at: indexPath).height
                self.selectedCellAndHisHeight[indexPath] = offset // default value
            }
            
            let isLastCell = self.isLastSectionAndRow(indexPath: indexPath)
            self.reloadTableViewHeight(lastCelIsClosed: isLastCell)
        }
        
        cell.isSelected = selectedCellAndHisHeight[indexPath] == nil
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
    
    private func reloadTableViewHeight(lastCelIsClosed: Bool = false) {
        let allHeight = selectedCellAndHisHeight.arrayOfValues.reduce(into: 0) { $0 += $1 - defaultRowHeight }
        let heightOfTableView = currentPlaylist.countOfValues.cgFloat * defaultRowHeight + allHeight + sumOfHeightsOfAllHeaders
        myDataSource?.episodeTableViewDidChangeHeightTableView(self, height: heightOfTableView, withLastCell: lastCelIsClosed)
    }
    
    private func isLastSectionAndRow(indexPath: IndexPath) -> Bool {
        return currentPlaylist.count - 1 == indexPath.section && currentPlaylist[indexPath.section].podcasts.count - 1 == indexPath.row
    }
    
    private func setHeightOfEpisodeTableView() -> CGFloat {
         return currentPlaylist.countOfValues.cgFloat * defaultRowHeight + sumOfHeightsOfAllHeaders
    }
    
    private func updateDownloadInformation(for entity: DownloadServiceType) {
        if let podcast = entity.downloadProtocol as? Podcast {
            currentPlaylist.getIndexPath(for: podcast).forEach {
                let cell = cellForRow(at: $0)
                if let cell = cell as? PodcastCell {
                    cell.updateDownloadInformation(with: entity)
                }
            }
        }
    }
}

//MARK: - UITableViewDataSource
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
        let cell = getCell(cell: PodcastCell.self, indexPath: indexPath)
        let podcast = currentPlaylist[indexPath.section].podcasts[indexPath.row]
        cell.isSelected = selectedCellAndHisHeight[indexPath] != nil
        cell.addMyGestureRecognizer(self, type: .tap(), #selector(tapCell))
        cell.configureCell(self, with: PodcastCellType(podcast: podcast))
        return cell
    }
}

//MARK: - UITableViewDelegate
extension EpisodeTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedCellAndHisHeight[indexPath] != nil {
            if let cell = cellForRow(at: indexPath) as? PodcastCell, cell.moreThanThreeLines {
                return UITableView.automaticDimension
            }
        }
        return defaultRowHeight
    }
}

//MARK: - PodcastCellDelegate
extension EpisodeTableView: PodcastCellDelegate {
    
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell, entity: PodcastCellType) {
        guard let indexPath = indexPath(for: podcastCell) else { return }
        let podcast = currentPlaylist[indexPath.section].podcasts[indexPath.row]
        myDelegate?.episodeTableView(self, addToFavoriteButtonDidTouchFor: podcast)
        podcastCell.updateFavoriteStar(with: podcast.isFavorite)
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell, entity: PodcastCellType) {
        guard let indexPath = indexPath(for: podcastCell) else { return }
        let podcast = currentPlaylist[indexPath.section].podcasts[indexPath.row]
        myDelegate?.episodeTableViewDidSelectDownLoadImage(self, entity: podcast)
    }
    
    func podcastCellDidTouchPlayButton(_ podcastCell: PodcastCell, entity: PodcastCellType) {
        guard let indexPath = indexPath(for: podcastCell) else { return }
        let podcast = currentPlaylist[indexPath.section].podcasts[indexPath.row]
        myDelegate?.episodeTableViewPlayButtonDidTouchFor(self, podcast: podcast, playlist: currentPlaylist.flatMap { $0.podcasts })
    }
    
    func podcastCellDidTouchStopButton(_ podcastCell: PodcastCell, entity: PodcastCellType) {
//        guard let indexPath = indexPath(for: podcastCell) else { return }
//        let podcast = currentPlaylist[indexPath.section].podcasts[indexPath.row]
        myDelegate?.episodeTableViewStopButtonDidTouchFor(self)
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
        if let cell = getCell(id: player.identifier) {
            cell.updatePlayerInformation(with: player)
        }
    }
    
    func playerStartLoading(notification: NSNotification) {
        guard let player = notification.object as? EpisodeTableViewPlayableProtocol else { return }
        if let cell = getCell(id: player.identifier) {
            cell.updatePlayerInformation(with: player)
        }
        
    }
    
    func playerDidEndLoading(notification: NSNotification) {
        guard let player = notification.object as? EpisodeTableViewPlayableProtocol else { return }
        if let cell = getCell(id: player.identifier) {
            cell.updatePlayerInformation(with: player)
        }
    }
    
    func playerUpdatePlayingInformation(notification: NSNotification) {
        guard let player = notification.object as? EpisodeTableViewPlayableProtocol else { return }
        if let cell = getCell(id: player.identifier) {
            cell.updatePlayerInformation(with: player)
        }
    }
    
    func playerStateDidChanged(notification: NSNotification) {
        guard let player = notification.object as? EpisodeTableViewPlayableProtocol else { return }
        if let cell = getCell(id: player.identifier) {
            cell.updatePlayerInformation(with: player)
        }
    }
}

//MARK: - DownloadServiceDelegate
extension EpisodeTableView: DownloadServiceDelegate {
  
    func updateDownloadInformation(_ downloadService: DownloadService, entity: DownloadServiceType) {
        updateDownloadInformation(for: entity)
    }
    
    func didEndDownloading(_ downloadService: DownloadService, entity: DownloadServiceType) {
        updateDownloadInformation(for: entity)
    }
    
    func didPauseDownload(_ downloadService: DownloadService, entity: DownloadServiceType) {
        updateDownloadInformation(for: entity)
    }
    
    func didContinueDownload(_ downloadService: DownloadService, entity: DownloadServiceType) {
        updateDownloadInformation(for: entity)
    }
    
    func didStartDownload(_ downloadService: DownloadService, entity: DownloadServiceType) {
        updateDownloadInformation(for: entity)
    }
    
    func didRemoveEntity(_ downloadService: DownloadService, entity: DownloadServiceType) {
        updateDownloadInformation(for: entity)
    }
}


