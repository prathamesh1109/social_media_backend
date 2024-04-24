-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 24, 2024 at 05:51 AM
-- Server version: 10.4.24-MariaDB
-- PHP Version: 7.4.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `social_media`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ADD_NEW_STORY` (IN `IDSTORY` VARCHAR(100), IN `IDUSER` VARCHAR(100), IN `IDMEDIASTORY` VARCHAR(100), IN `MEDIA` VARCHAR(150))   BEGIN
	INSERT INTO stories (uid_story, user_uid) VALUE (IDSTORY,IDUSER);
	INSERT INTO media_story(uid_media_story, media, story_uid) VALUE (IDMEDIASTORY, MEDIA, IDSTORY);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ALL_MESSAGE_BY_USER` (IN `UIDFROM` VARCHAR(100), IN `UIDTO` VARCHAR(100))   BEGIN	
	SELECT * FROM messages me
	WHERE me.source_uid = UIDFROM AND me.target_uid = UIDTO || me.source_uid = UIDTO AND me.target_uid = UIDFROM
	ORDER BY me.created_at DESC
	LIMIT 30;  
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_FOLLOWERS` (IN `IDUSER` VARCHAR(100))   BEGIN
	SELECT f.uid AS idFollower, f.followers_uid AS uid_user, f.date_followers, u.username, p.fullname, p.image AS avatar FROM followers f
	INNER JOIN users u ON f.followers_uid = u.person_uid
	INNER JOIN person p ON u.person_uid = p.uid
	WHERE f.person_uid = IDUSER;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_FOLLOWING` (IN `IDUSER` VARCHAR(100))   BEGIN
	SELECT f.uid AS uid_friend, f.friend_uid AS uid_user, f.date_friend, u.username, p.fullname, p.image AS avatar 
	FROM friends f
	INNER JOIN users u ON f.friend_uid = u.person_uid
	INNER JOIN person p ON u.person_uid = p.uid
	WHERE f.person_uid = IDUSER;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_MESSAGE_BY_USER` (IN `IDUSER` VARCHAR(100))   BEGIN
	SELECT ls.uid_list_chat, ls.source_uid, ls.target_uid, ls.last_message, ls.updated_at, u.username, p.image AS avatar
	FROM list_chats ls
	INNER JOIN users u ON ls.target_uid = u.person_uid
	INNER JOIN person p ON u.person_uid = p.uid
 	WHERE ls.source_uid = IDUSER
 	ORDER BY ls.updated_at ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_POSTS_FOR_SEARCH` (IN `ID` VARCHAR(100))   BEGIN
	SELECT img.post_uid AS post_uid, pos.is_comment, pos.type_privacy, pos.created_at, pos.person_uid, username AS username, per.image AS avatar, GROUP_CONCAT( DISTINCT img.image ) images  
	FROM images_post img
	INNER JOIN posts pos  ON img.post_uid = pos.uid
	INNER JOIN users us ON us.person_uid = pos.person_uid
	INNER JOIN person per ON per.uid = pos.person_uid
	WHERE pos.person_uid <> ID AND pos.type_privacy = 1
	GROUP BY img.post_uid
	ORDER BY pos.uid DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_POSTS_HOME` (IN `ID` VARCHAR(100))   BEGIN
	SELECT img.post_uid AS post_uid, pos.is_comment, pos.type_privacy, pos.created_at, pos.person_uid, username AS username, 
	per.image AS avatar, GROUP_CONCAT( DISTINCT img.image ) images, 
	(SELECT COUNT(co.post_uid) FROM comments co WHERE co.post_uid = pos.uid ) AS count_comment,
	(SELECT COUNT(li.post_uid) FROM likes li WHERE li.post_uid = pos.uid ) AS count_likes,
	(SELECT COUNT(li.user_uid) FROM likes li WHERE li.user_uid = ID AND li.post_uid = pos.uid )AS is_like
	FROM images_post img
	INNER JOIN posts pos  ON img.post_uid = pos.uid
	INNER JOIN comments co ON co.post_uid = pos.uid
	INNER JOIN users us ON us.person_uid = pos.person_uid
	INNER JOIN person per ON per.uid = pos.person_uid
	LEFT JOIN friends f ON f.friend_uid = per.uid
	WHERE f.person_uid = ID OR pos.person_uid = ID
	GROUP BY img.post_uid, co.post_uid 
	ORDER BY pos.created_at DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_POST_BY_USER` (IN `ID` VARCHAR(100))   BEGIN
	SELECT img.post_uid AS post_uid, pos.is_comment, pos.type_privacy, pos.created_at, pos.person_uid, ANY_VALUE(username) AS username, 
	per.image AS avatar, GROUP_CONCAT( DISTINCT img.image ) images, 
	(SELECT COUNT(co.post_uid) FROM comments co WHERE co.post_uid = pos.uid ) AS count_comment,
	(SELECT COUNT(li.post_uid) FROM likes li WHERE li.post_uid = pos.uid ) AS count_likes,
	(SELECT COUNT(li.user_uid) FROM likes li WHERE li.user_uid = ID AND li.post_uid = pos.uid )AS is_like
	FROM images_post img
	INNER JOIN posts pos  ON img.post_uid = pos.uid
	INNER JOIN comments co ON co.post_uid = pos.uid
	INNER JOIN users us ON us.person_uid = pos.person_uid
	INNER JOIN person per ON per.uid = pos.person_uid
	WHERE per.uid = ID
	GROUP BY img.post_uid, co.post_uid 
	ORDER BY pos.created_at DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_ALL_STORIES_HOME` (IN `IDUSER` VARCHAR(100))   BEGIN
	SELECT s.uid_story, u.username, p.image AS avatar, COUNT(ms.story_uid) AS count_story
	FROM stories s
	INNER JOIN users u ON s.user_uid = u.person_uid
	INNER JOIN media_story ms ON s.uid_story = ms.story_uid
	INNER JOIN friends f ON u.person_uid = f.friend_uid
	INNER JOIN person p ON p.uid = f.friend_uid
	WHERE f.person_uid =  IDUSER
	GROUP BY s.uid_story, u.username, p.image;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_COMMNETS_BY_UIDPOST` (IN `IDPOST` VARCHAR(100))   BEGIN
	SELECT co.uid, co.`comment`, co.is_like, co.created_at, co.person_uid, co.post_uid, u.username, p.image AS avatar FROM comments co
	INNER JOIN users u ON co.person_uid = u.person_uid
	INNER JOIN person p ON p.uid = co.person_uid
	WHERE co.post_uid = IDPOST
	ORDER BY co.created_at ASC; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_LIST_POST_SAVED_BY_USER` (IN `ID` VARCHAR(100))   BEGIN
	SELECT ps.post_save_uid, ps.post_uid, ps.person_uid, ps.date_save, per.image AS avatar, username AS username, GROUP_CONCAT( DISTINCT img.image ) images FROM post_save ps 
	INNER JOIN posts po ON ps.post_uid = po.uid
	INNER JOIN images_post img ON po.uid = img.post_uid
	INNER JOIN person per ON per.uid = ps.person_uid
	INNER JOIN users us ON us.person_uid = ps.person_uid
	where ps.person_uid = ID
	GROUP BY ps.post_save_uid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_NOTIFICATION_BY_USER` (IN `ID` VARCHAR(100))   BEGIN
	SELECT noti.uid_notification, noti.type_notification, noti.created_at, noti.user_uid, u.username, noti.followers_uid, s.username AS follower, pe.image AS avatar, noti.post_uid 
	FROM notifications noti
	INNER JOIN users u ON noti.user_uid = u.person_uid
	INNER JOIN users s ON noti.followers_uid = s.person_uid
	INNER JOIN person pe ON pe.uid = s.person_uid
	WHERE noti.user_uid = ID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_POST_BY_IDPERSON` (IN `ID` VARCHAR(100))   BEGIN
	SELECT img.post_uid AS post_uid, pos.is_comment, pos.type_privacy, pos.created_at, GROUP_CONCAT( DISTINCT img.image ) images  
	FROM images_post img
	INNER JOIN posts pos  ON img.post_uid = pos.uid
	WHERE pos.person_uid = ID
	GROUP BY img.post_uid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_POST_BY_ID_PERSON` (IN `ID` VARCHAR(100))   BEGIN
	SELECT pos.uid, pos.is_comment, pos.type_privacy, pos.created_at, GROUP_CONCAT( DISTINCT img.image ) images FROM images_post img
	INNER JOIN posts pos  ON img.post_uid = pos.uid
	WHERE pos.person_uid = ID
	GROUP BY pos.uid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_STORY_BY_USER` (IN `IDSTORY` VARCHAR(100))   BEGIN
	SELECT *
	FROM media_story ms
	WHERE ms.story_uid = IDSTORY;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_USER_BY_ID` (IN `ID` VARCHAR(100))   BEGIN
	SELECT p.uid, p.fullname, p.phone, p.image, p.cover, p.birthday_date, p.created_at, u.username, u.description, u.is_private, u.is_online, u.email
	FROM person p
	INNER JOIN users u ON p.uid = u.person_uid
	WHERE p.uid = ID AND p.state = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_IS_FRIEND` (IN `UID` VARCHAR(100), IN `FRIEND` VARCHAR(100))   BEGIN
	SELECT COUNT(uid) AS is_friend FROM friends
	WHERE person_uid = UID AND friend_uid = FRIEND
	LIMIT 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_IS_PENDING_FOLLOWER` (IN `UIDPERSON` VARCHAR(100), IN `UIDFOLLOWER` VARCHAR(100))   BEGIN
	SELECT COUNT(uid_notification) AS is_pending_follower FROM notifications
	WHERE user_uid = UIDPERSON AND followers_uid = UIDFOLLOWER AND type_notification = '1';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_REGISTER_USER` (IN `uidPerson` VARCHAR(100), IN `fullname` VARCHAR(100), IN `username` VARCHAR(50), IN `email` VARCHAR(100), IN `pass` VARCHAR(100), IN `uidUser` VARCHAR(100), IN `temp` VARCHAR(50))   BEGIN
	INSERT INTO person(uid, fullname, image) VALUE (uidPerson, fullname, 'avatar-default.png');
	
	INSERT INTO users(uid, username, email, passwordd, person_uid, token_temp, email_verified) VALUE (uidUser, username, email, pass, uidPerson, temp, 1);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEARCH_USERNAME` (IN `USERNAMEE` VARCHAR(100))   BEGIN
	SELECT pe.uid, pe.fullname, pe.image AS avatar, us.username FROM person pe
	INNER JOIN users us ON pe.uid = us.person_uid
	WHERE pe.fullname LIKE CONCAT('%', USERNAMEE, '%');
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `comments`
--

CREATE TABLE `comments` (
  `uid` varchar(100) NOT NULL,
  `comment` varchar(150) DEFAULT NULL,
  `is_like` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  `person_uid` varchar(100) NOT NULL,
  `post_uid` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `followers`
--

CREATE TABLE `followers` (
  `uid` varchar(100) NOT NULL,
  `person_uid` varchar(100) NOT NULL,
  `followers_uid` varchar(100) NOT NULL,
  `date_followers` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `followers`
--

INSERT INTO `followers` (`uid`, `person_uid`, `followers_uid`, `date_followers`) VALUES
('2e7732d8-b43e-408c-8614-cd0dcdfa738e', '7b135f3e-1ded-4722-8def-c93742470c71', 'f298b59c-3de3-458f-bbb5-c10af5eaf9e4', '2024-04-04 11:20:04'),
('c3ed24ad-e913-4142-ba33-ce45da3a6d8c', 'f298b59c-3de3-458f-bbb5-c10af5eaf9e4', '7b135f3e-1ded-4722-8def-c93742470c71', '2024-04-05 18:45:20');

-- --------------------------------------------------------

--
-- Table structure for table `friends`
--

CREATE TABLE `friends` (
  `uid` varchar(100) NOT NULL,
  `person_uid` varchar(100) NOT NULL,
  `friend_uid` varchar(100) NOT NULL,
  `date_friend` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `friends`
--

INSERT INTO `friends` (`uid`, `person_uid`, `friend_uid`, `date_friend`) VALUES
('c3d8fb8c-1506-4925-9da9-766758e1cbcb', '7b135f3e-1ded-4722-8def-c93742470c71', 'f298b59c-3de3-458f-bbb5-c10af5eaf9e4', '2024-04-05 18:45:20'),
('f1dd8d1d-e623-4071-a31c-6273413073c7', 'f298b59c-3de3-458f-bbb5-c10af5eaf9e4', '7b135f3e-1ded-4722-8def-c93742470c71', '2024-04-04 11:20:04');

-- --------------------------------------------------------

--
-- Table structure for table `images_post`
--

CREATE TABLE `images_post` (
  `uid` varchar(100) NOT NULL,
  `image` varchar(255) NOT NULL,
  `post_uid` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `likes`
--

CREATE TABLE `likes` (
  `uid_likes` varchar(100) NOT NULL,
  `user_uid` varchar(100) NOT NULL,
  `post_uid` varchar(100) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `list_chats`
--

CREATE TABLE `list_chats` (
  `uid_list_chat` varchar(100) NOT NULL,
  `source_uid` varchar(100) NOT NULL,
  `target_uid` varchar(100) NOT NULL,
  `last_message` text DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `list_chats`
--

INSERT INTO `list_chats` (`uid_list_chat`, `source_uid`, `target_uid`, `last_message`, `updated_at`) VALUES
('14ee1a36-b0ba-4b88-9594-8f07497f614f', 'f298b59c-3de3-458f-bbb5-c10af5eaf9e4', '7b135f3e-1ded-4722-8def-c93742470c71', 'what about you', '2024-04-04 09:31:05'),
('6e3b791b-f237-40be-b314-c4f27eda1c59', '7b135f3e-1ded-4722-8def-c93742470c71', 'f298b59c-3de3-458f-bbb5-c10af5eaf9e4', 'mee too', '2024-04-04 09:31:20');

-- --------------------------------------------------------

--
-- Table structure for table `media_story`
--

CREATE TABLE `media_story` (
  `uid_media_story` varchar(100) NOT NULL,
  `media` varchar(150) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `story_uid` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `uid_messages` varchar(100) NOT NULL,
  `source_uid` varchar(100) NOT NULL,
  `target_uid` varchar(100) NOT NULL,
  `message` text NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`uid_messages`, `source_uid`, `target_uid`, `message`, `created_at`) VALUES
('11134dab-b38e-410d-848a-3e6f7b005550', 'f298b59c-3de3-458f-bbb5-c10af5eaf9e4', '7b135f3e-1ded-4722-8def-c93742470c71', 'i am fine', '2024-04-04 15:00:47'),
('3fec3665-418c-4957-8a4f-8ef08508233f', '7b135f3e-1ded-4722-8def-c93742470c71', 'f298b59c-3de3-458f-bbb5-c10af5eaf9e4', 'test', '2024-04-04 14:58:30'),
('611b05a6-bce4-4481-925d-b62abb657785', '7b135f3e-1ded-4722-8def-c93742470c71', 'f298b59c-3de3-458f-bbb5-c10af5eaf9e4', 'how are you', '2024-04-04 15:00:23'),
('9a9d3460-6dca-4ed5-b29c-7a73ef359691', '7b135f3e-1ded-4722-8def-c93742470c71', 'f298b59c-3de3-458f-bbb5-c10af5eaf9e4', 'mee too', '2024-04-04 15:01:20'),
('9e4a5e23-5dd2-4da2-9be3-027c02898ef7', 'f298b59c-3de3-458f-bbb5-c10af5eaf9e4', '7b135f3e-1ded-4722-8def-c93742470c71', 'what about you', '2024-04-04 15:01:05'),
('e31d1286-cc0a-487e-bf3a-61023f9e74f7', 'f298b59c-3de3-458f-bbb5-c10af5eaf9e4', '7b135f3e-1ded-4722-8def-c93742470c71', 'hello', '2024-04-04 14:59:56');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `uid_notification` varchar(100) NOT NULL,
  `type_notification` varchar(5) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `user_uid` varchar(100) NOT NULL,
  `followers_uid` varchar(100) DEFAULT NULL,
  `post_uid` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `person`
--

CREATE TABLE `person` (
  `uid` varchar(100) NOT NULL,
  `fullname` varchar(150) DEFAULT NULL,
  `phone` varchar(11) DEFAULT NULL,
  `image` varchar(250) DEFAULT NULL,
  `cover` varchar(50) DEFAULT NULL,
  `birthday_date` date DEFAULT NULL,
  `state` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `person`
--

INSERT INTO `person` (`uid`, `fullname`, `phone`, `image`, `cover`, `birthday_date`, `state`, `created_at`, `updated_at`) VALUES
('7b135f3e-1ded-4722-8def-c93742470c71', 'prathamesh', NULL, 'avatar-default.png', NULL, NULL, 1, '2024-04-04 10:24:05', '2024-04-04 10:24:05'),
('f298b59c-3de3-458f-bbb5-c10af5eaf9e4', 'prathamesh 1', NULL, 'avatar-default.png', NULL, NULL, 1, '2024-04-04 10:53:51', '2024-04-04 10:53:51');

-- --------------------------------------------------------

--
-- Table structure for table `posts`
--

CREATE TABLE `posts` (
  `uid` varchar(100) NOT NULL,
  `is_comment` tinyint(1) DEFAULT 1,
  `type_privacy` varchar(3) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `upadted_at` datetime DEFAULT current_timestamp(),
  `person_uid` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `post_save`
--

CREATE TABLE `post_save` (
  `post_save_uid` varchar(100) NOT NULL,
  `post_uid` varchar(100) NOT NULL,
  `person_uid` varchar(100) NOT NULL,
  `date_save` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `stories`
--

CREATE TABLE `stories` (
  `uid_story` varchar(100) NOT NULL,
  `user_uid` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `uid` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `is_private` tinyint(1) DEFAULT 0,
  `is_online` tinyint(1) DEFAULT 0,
  `email` varchar(100) NOT NULL,
  `passwordd` varchar(100) NOT NULL,
  `email_verified` tinyint(1) DEFAULT 0,
  `person_uid` varchar(100) NOT NULL,
  `notification_token` varchar(255) DEFAULT NULL,
  `token_temp` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`uid`, `username`, `description`, `is_private`, `is_online`, `email`, `passwordd`, `email_verified`, `person_uid`, `notification_token`, `token_temp`) VALUES
('5a8fe3f0-536f-4fe5-9c7c-98b7dc33933d', 'tamboli', NULL, 0, 0, 'prathamesh1109@gmail.com', '$2b$10$bB4Pk0AGihjrh.NZjAKxOO41I8WS/EjJRTNqQLX3hr3nlHqAj74o6', 1, '7b135f3e-1ded-4722-8def-c93742470c71', NULL, '82174'),
('c3e0dbfd-90ae-4354-9792-239a595e5785', 'tamboli 1', NULL, 0, 0, 'prathamesh11091@gmail.com', '$2b$10$PEy915WX/.JAu.q4QmYMWerJs210cYljRQXnFC4MEJSjAaOR6QlBK', 1, 'f298b59c-3de3-458f-bbb5-c10af5eaf9e4', NULL, '51633');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `comments`
--
ALTER TABLE `comments`
  ADD PRIMARY KEY (`uid`),
  ADD KEY `person_uid` (`person_uid`),
  ADD KEY `post_uid` (`post_uid`);

--
-- Indexes for table `followers`
--
ALTER TABLE `followers`
  ADD PRIMARY KEY (`uid`),
  ADD KEY `person_uid` (`person_uid`),
  ADD KEY `followers_uid` (`followers_uid`);

--
-- Indexes for table `friends`
--
ALTER TABLE `friends`
  ADD PRIMARY KEY (`uid`),
  ADD KEY `person_uid` (`person_uid`),
  ADD KEY `friend_uid` (`friend_uid`);

--
-- Indexes for table `images_post`
--
ALTER TABLE `images_post`
  ADD PRIMARY KEY (`uid`),
  ADD KEY `post_uid` (`post_uid`);

--
-- Indexes for table `likes`
--
ALTER TABLE `likes`
  ADD PRIMARY KEY (`uid_likes`),
  ADD KEY `user_uid` (`user_uid`),
  ADD KEY `post_uid` (`post_uid`);

--
-- Indexes for table `list_chats`
--
ALTER TABLE `list_chats`
  ADD PRIMARY KEY (`uid_list_chat`),
  ADD KEY `source_uid` (`source_uid`),
  ADD KEY `target_uid` (`target_uid`);

--
-- Indexes for table `media_story`
--
ALTER TABLE `media_story`
  ADD PRIMARY KEY (`uid_media_story`),
  ADD KEY `story_uid` (`story_uid`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`uid_messages`),
  ADD KEY `source_uid` (`source_uid`),
  ADD KEY `target_uid` (`target_uid`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`uid_notification`),
  ADD KEY `user_uid` (`user_uid`),
  ADD KEY `followers_uid` (`followers_uid`),
  ADD KEY `post_uid` (`post_uid`);

--
-- Indexes for table `person`
--
ALTER TABLE `person`
  ADD PRIMARY KEY (`uid`);

--
-- Indexes for table `posts`
--
ALTER TABLE `posts`
  ADD PRIMARY KEY (`uid`),
  ADD KEY `person_uid` (`person_uid`);

--
-- Indexes for table `post_save`
--
ALTER TABLE `post_save`
  ADD PRIMARY KEY (`post_save_uid`),
  ADD KEY `post_uid` (`post_uid`),
  ADD KEY `person_uid` (`person_uid`);

--
-- Indexes for table `stories`
--
ALTER TABLE `stories`
  ADD PRIMARY KEY (`uid_story`),
  ADD KEY `user_uid` (`user_uid`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`uid`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `person_uid` (`person_uid`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `comments`
--
ALTER TABLE `comments`
  ADD CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`person_uid`) REFERENCES `person` (`uid`),
  ADD CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`post_uid`) REFERENCES `posts` (`uid`);

--
-- Constraints for table `followers`
--
ALTER TABLE `followers`
  ADD CONSTRAINT `followers_ibfk_1` FOREIGN KEY (`person_uid`) REFERENCES `person` (`uid`),
  ADD CONSTRAINT `followers_ibfk_2` FOREIGN KEY (`followers_uid`) REFERENCES `person` (`uid`);

--
-- Constraints for table `friends`
--
ALTER TABLE `friends`
  ADD CONSTRAINT `friends_ibfk_1` FOREIGN KEY (`person_uid`) REFERENCES `person` (`uid`),
  ADD CONSTRAINT `friends_ibfk_2` FOREIGN KEY (`friend_uid`) REFERENCES `person` (`uid`);

--
-- Constraints for table `images_post`
--
ALTER TABLE `images_post`
  ADD CONSTRAINT `images_post_ibfk_1` FOREIGN KEY (`post_uid`) REFERENCES `posts` (`uid`);

--
-- Constraints for table `likes`
--
ALTER TABLE `likes`
  ADD CONSTRAINT `likes_ibfk_1` FOREIGN KEY (`user_uid`) REFERENCES `users` (`person_uid`),
  ADD CONSTRAINT `likes_ibfk_2` FOREIGN KEY (`post_uid`) REFERENCES `posts` (`uid`);

--
-- Constraints for table `list_chats`
--
ALTER TABLE `list_chats`
  ADD CONSTRAINT `list_chats_ibfk_1` FOREIGN KEY (`source_uid`) REFERENCES `person` (`uid`),
  ADD CONSTRAINT `list_chats_ibfk_2` FOREIGN KEY (`target_uid`) REFERENCES `person` (`uid`);

--
-- Constraints for table `media_story`
--
ALTER TABLE `media_story`
  ADD CONSTRAINT `media_story_ibfk_1` FOREIGN KEY (`story_uid`) REFERENCES `stories` (`uid_story`) ON DELETE CASCADE;

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`source_uid`) REFERENCES `users` (`person_uid`),
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`target_uid`) REFERENCES `users` (`person_uid`);

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_uid`) REFERENCES `users` (`person_uid`),
  ADD CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`followers_uid`) REFERENCES `users` (`person_uid`),
  ADD CONSTRAINT `notifications_ibfk_3` FOREIGN KEY (`post_uid`) REFERENCES `posts` (`uid`);

--
-- Constraints for table `posts`
--
ALTER TABLE `posts`
  ADD CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`person_uid`) REFERENCES `person` (`uid`);

--
-- Constraints for table `post_save`
--
ALTER TABLE `post_save`
  ADD CONSTRAINT `post_save_ibfk_1` FOREIGN KEY (`post_uid`) REFERENCES `posts` (`uid`),
  ADD CONSTRAINT `post_save_ibfk_2` FOREIGN KEY (`person_uid`) REFERENCES `person` (`uid`);

--
-- Constraints for table `stories`
--
ALTER TABLE `stories`
  ADD CONSTRAINT `stories_ibfk_1` FOREIGN KEY (`user_uid`) REFERENCES `users` (`person_uid`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`person_uid`) REFERENCES `person` (`uid`);

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`root`@`localhost` EVENT `delete_story_after_24_hours` ON SCHEDULE AT '2024-04-05 10:02:51' ON COMPLETION NOT PRESERVE ENABLE DO DELETE FROM media_story WHERE created_at < ( CURRENT_TIMESTAMP - INTERVAL 1 DAY );$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
