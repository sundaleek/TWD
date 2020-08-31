import UIKit
import SnapKit
import SDWebImage

class TableViewCell: UITableViewCell {

    let iv: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        return iv
    }()

    let titleLabel: UILabel = {
        let t = UILabel()
        t.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        t.text = "SomeTitle"
        t.numberOfLines = 0
        return t
    }()

    let arrow: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.image = UIImage(named: "arrow_left")
        iv.tintColor = .lightGray
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(iv)
        addSubview(titleLabel)
        addSubview(arrow)

        iv.snp.makeConstraints { (m) in
            m.top.left.bottom.equalToSuperview().inset(15)
            m.width.height.equalTo(50.0)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.left.equalTo(iv.snp.right).inset(-10)
            m.top.equalToSuperview()
            m.right.equalToSuperview().inset(25)
            m.bottom.equalToSuperview().inset(15)
        }

//        subtitleLabel.snp.makeConstraints { (m) in
//            m.left.equalTo(iv.snp.right).inset(-10)
//            m.top.equalTo(titleLabel.snp.bottom).inset(-10)
//            m.bottom.equalToSuperview().inset(15)
//            m.right.equalToSuperview().inset(35)
//        }

        arrow.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.right.equalToSuperview().inset(15)
            m.width.equalTo(10)
            m.height.equalTo(16)
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with tweet: Tweet) {
        titleLabel.text = tweet.text
        iv.sd_setImage(with: URL(string: tweet.previewUrl))
    }
}
