//
//  ViewController.swift
//  RockPaperScissors
//
//  Created by Masami on 2023/03/12.
//

import UIKit

final class ViewController: UIViewController {

    /// 勝敗の種類
    enum JudgementType {
        case lose // 負け
        case draw // 引き分け
        case win // 勝ち
        
        var result: String {
            switch self {
            case .lose:
                return "負け"
            case .draw:
                return "引き分け"
            case .win:
                return "勝ち"
            }
        }
    }

    // じゃんけんの手の種類
    enum HandType: Int {
        case paper // パー
        case rock // グー
        case scissors // チョキ
        
        // 手の種類の画像を取得する
        var image: UIImage? {
            switch self {
            case .rock:
                return UIImage(named: "Rock")
            case .scissors:
                return UIImage(named: "Scissors")
            case .paper:
                return UIImage(named: "Paper")
            }
        }
    }

    // 相手が手を変える頻度(例: 10秒に1回変更する場合は、10を入れる)
    let refreshSec: Double = 0.1

    // 相手の手の種類を保持する場所
    var opponentHandType: HandType = .rock {
        didSet {
            guard !isShowingAlert else {
                return
            }
            setHandImage(type: opponentHandType)
        }
    }

    // 相手のハンドの種類を更新するためのタスク
    var task: Task<Void, Never>?
    
    var isShowingAlert: Bool = false

    /// 相手が何を出したか表示するイメージビュー
    @IBOutlet private weak var handImageView: UIImageView!

    /// グーボタンを押した時に動く処理
    /// - Parameter sender: UIButton
    @IBAction func selectRock(_ sender: UIButton) {
        let judgementType = victoryJudgment(type: .rock)
        showResultAlert(judgementType: judgementType)
    }

    /// チョキボタンを押した時に動く処理
    /// - Parameter sender: UIButton
    @IBAction func selectScissors(_ sender: UIButton) {
        let judgementType = victoryJudgment(type: .scissors)
        showResultAlert(judgementType: judgementType)
    }

    /// パーボタンを押した時に動く処理
    /// - Parameter sender: UIButton
    @IBAction func selectPaper(_ sender: UIButton) {
        let judgementType = victoryJudgment(type: .paper)
        showResultAlert(judgementType: judgementType)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // タスクの初期設定を行う
        setupHandRefreshTask()
    }

    /// 相手の出す手を設定する処理
    func setupHandRefreshTask() {
        guard !isShowingAlert else {
            return
        }
        task = Task {
            // 指定秒数処理を待つ
            try? await Task.sleep(nanoseconds: UInt64(refreshSec * 1_000_000_000))
            // 0から2の乱数を生成する
            let random = Int.random(in: 0..<2)
            if let nextHandType = HandType(rawValue: random) {
                opponentHandType = nextHandType
            }
            // 次のタスクを設定する
            setupHandRefreshTask()
        }
    }

    /// 相手の手の画像を設定する
    /// - Parameter type: OpponentHandType
    func setHandImage(type: HandType) {
        handImageView.image = type.image
    }

    /// 勝敗の判定を行う
    /// - Parameter type: 自分の出した手の種類
    /// - Returns: 勝ち負けの結果
    func victoryJudgment(type: HandType) -> JudgementType {
        guard type != opponentHandType else {
            // 相手の手と一致した場合は、引き分け
            return .draw
        }
        switch type {
        case .paper where opponentHandType == .rock:
            // 自分の手がパー、相手がグーの時は勝ち
            return .win
        case .rock where opponentHandType == .scissors:
            // 自分の手がグー、相手がチョキの時は勝ち
            return .win
        case .scissors where opponentHandType == .paper:
            // 自分の手がチョキ、相手がパーの時は勝ち
            return .win
        default:
            // それ以外の場合は、負け
            return .lose
        }
    }

    /// 勝敗のアラートを表示する
    /// - Parameter judgementType: 勝敗の結果
    func showResultAlert(judgementType: JudgementType) {
        let title = "勝敗の結果"
        let body = judgementType.result
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.isShowingAlert = false
            self?.setupHandRefreshTask()
        })
        alert.addAction(action)
        isShowingAlert = true
        present(alert, animated: true)
    }
}

