--
-- PostgreSQL database dump
--

\restrict rz0mPW1msWtVg3rbeJKotBcxOc4YgtVuRl4h4yfhkC3DLU6b0T2Jfx3y0b3Qfcb

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: chat_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_members (
    chat_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role character varying(20) DEFAULT 'member'::character varying,
    last_read_message_id uuid,
    muted_until timestamp without time zone,
    is_pinned boolean DEFAULT false,
    joined_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.chat_members OWNER TO postgres;

--
-- Name: chats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chats (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100),
    chat_type character varying(20) NOT NULL,
    pinned_message_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.chats OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    chat_id uuid,
    sender_id uuid,
    type character varying(20) DEFAULT 'text'::character varying,
    text text,
    media_url text,
    reply_to_id uuid,
    status character varying(20) DEFAULT 'sent'::character varying,
    is_deleted boolean DEFAULT false,
    edited_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    username character varying(50) NOT NULL,
    phone character varying(20),
    avatar_url text,
    bio text,
    last_seen timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    password_hash text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: chat_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_members (chat_id, user_id, role, last_read_message_id, muted_until, is_pinned, joined_at) FROM stdin;
98a9da29-cc04-42cd-a1a3-43251e8c19fb	81ebe17f-263d-4404-8c52-057d2c613a9a	member	\N	\N	f	2026-06-24 15:00:07.843704
98a9da29-cc04-42cd-a1a3-43251e8c19fb	8da93c5b-c965-4086-a486-dc12a9963733	member	\N	\N	f	2026-06-24 15:00:07.843704
59bd22cd-3db1-4d2f-9fe3-90aa5ec8ca25	81ebe17f-263d-4404-8c52-057d2c613a9a	member	\N	\N	f	2026-06-24 15:00:10.136979
59bd22cd-3db1-4d2f-9fe3-90aa5ec8ca25	8da93c5b-c965-4086-a486-dc12a9963733	member	\N	\N	f	2026-06-24 15:00:10.136979
59bd22cd-3db1-4d2f-9fe3-90aa5ec8ca25	bd744d8e-d381-4014-a982-e8eeb1e80758	member	\N	\N	f	2026-06-24 15:00:10.136979
98a9da29-cc04-42cd-a1a3-43251e8c19fb	9768f0d9-ea40-48a2-8dea-d44e01316d10	member	\N	\N	f	2026-07-03 10:50:53.302851
65383c5e-d181-4320-abbd-b544a6958df6	965da357-fbbc-4d51-92ac-020d93d912c4	owner	\N	\N	f	2026-07-03 11:21:42.360889
65383c5e-d181-4320-abbd-b544a6958df6	9768f0d9-ea40-48a2-8dea-d44e01316d10	member	\N	\N	f	2026-07-03 11:21:42.365543
\.


--
-- Data for Name: chats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chats (id, name, chat_type, pinned_message_id, created_at) FROM stdin;
98a9da29-cc04-42cd-a1a3-43251e8c19fb	личные сообщения с emir	private	\N	2026-06-24 14:46:46.104161
dfc5e158-2583-4049-bb4c-cafddd959b74	общий чат	group	\N	2026-06-24 14:46:46.104161
59bd22cd-3db1-4d2f-9fe3-90aa5ec8ca25	Общий чат	group	\N	2026-06-24 14:57:04.062721
65383c5e-d181-4320-abbd-b544a6958df6	личный с тестуром	private	\N	2026-07-03 11:21:42.351706
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, chat_id, sender_id, type, text, media_url, reply_to_id, status, is_deleted, edited_at, created_at) FROM stdin;
69eebf13-2248-48b0-9819-b4ea2873bb83	98a9da29-cc04-42cd-a1a3-43251e8c19fb	81ebe17f-263d-4404-8c52-057d2c613a9a	text	Привет, господин, склоняюсь к твоим ногам	\N	\N	sent	f	\N	2026-06-24 15:05:58.832418
e08bdc2c-6eae-4bea-809b-06782dd94be2	98a9da29-cc04-42cd-a1a3-43251e8c19fb	8da93c5b-c965-4086-a486-dc12a9963733	text	вольно раб мой, сегодня помилую	\N	\N	sent	f	\N	2026-06-24 15:05:58.832418
fa1ee4bc-1fa3-495c-ae83-2c589c9587ea	98a9da29-cc04-42cd-a1a3-43251e8c19fb	81ebe17f-263d-4404-8c52-057d2c613a9a	text	о спасибо мой господин	\N	\N	sent	f	\N	2026-06-24 15:05:58.832418
06b03043-142c-4dc0-97d5-eeeeded98fc7	59bd22cd-3db1-4d2f-9fe3-90aa5ec8ca25	bd744d8e-d381-4014-a982-e8eeb1e80758	text	а это вроде зхс курсед не помню	\N	\N	sent	f	\N	2026-06-24 15:05:58.832418
906a0f0f-aa44-483b-84c2-8800e542cdc2	59bd22cd-3db1-4d2f-9fe3-90aa5ec8ca25	81ebe17f-263d-4404-8c52-057d2c613a9a	text	а здесь по задумке данил говорит, щас посмотрим как я айпишники ахуенно придумал, правильно ли он их ставит и генерит	\N	\N	sent	f	\N	2026-06-24 15:05:58.832418
49d4f045-2349-46c4-a231-82188c2148bc	59bd22cd-3db1-4d2f-9fe3-90aa5ec8ca25	8da93c5b-c965-4086-a486-dc12a9963733	text	одааааа одаааа в клубе ее подруги	\N	\N	sent	f	\N	2026-06-24 15:05:58.832418
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, phone, avatar_url, bio, last_seen, created_at, password_hash) FROM stdin;
81ebe17f-263d-4404-8c52-057d2c613a9a	danil	\N	\N	\N	\N	2026-06-24 14:40:35.591622	\N
8da93c5b-c965-4086-a486-dc12a9963733	emir	\N	\N	\N	\N	2026-06-24 14:40:35.591622	\N
bd744d8e-d381-4014-a982-e8eeb1e80758	zxcursed	\N	\N	\N	\N	2026-06-24 14:40:35.591622	\N
8670fcd6-fcdc-4c3e-82a4-088643a1770a	rimanetcz	\N	\N	\N	\N	2026-06-24 14:40:35.591622	\N
4b0da5af-a3f4-42b8-a9ff-b6d94c33566e	testuser2	\N	\N	\N	\N	2026-07-03 10:30:42.416562	$2a$10$1saZhipAnKG1lDSovGWWnOccEUpNMQxlQ2vaw8LKyUcCmX7bsQiZC
9768f0d9-ea40-48a2-8dea-d44e01316d10	testuser	\N	\N	пидорасы	\N	2026-07-02 19:21:52.700094	$2a$10$MF/rBOqREH20SscmNUAznuFRWn5tWRS7VTJrx.4AbrdW25Xnp.K36
965da357-fbbc-4d51-92ac-020d93d912c4	bananchik	\N	http://localhost:8080/uploads/e5a5bece-c1ec-4a94-9bbc-45858c7a7351.png	пидорасы	\N	2026-07-02 19:29:20.953432	$2a$10$S65ZwfodFTIN6xDIxSVDIuLfFRi.y6j0XU.uu4szQFVHbdEDhpUmi
\.


--
-- Name: chat_members chat_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_members
    ADD CONSTRAINT chat_members_pkey PRIMARY KEY (chat_id, user_id);


--
-- Name: chats chats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: chat_members chat_members_chat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_members
    ADD CONSTRAINT chat_members_chat_id_fkey FOREIGN KEY (chat_id) REFERENCES public.chats(id) ON DELETE CASCADE;


--
-- Name: chat_members chat_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_members
    ADD CONSTRAINT chat_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: messages messages_chat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_chat_id_fkey FOREIGN KEY (chat_id) REFERENCES public.chats(id) ON DELETE CASCADE;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict rz0mPW1msWtVg3rbeJKotBcxOc4YgtVuRl4h4yfhkC3DLU6b0T2Jfx3y0b3Qfcb

