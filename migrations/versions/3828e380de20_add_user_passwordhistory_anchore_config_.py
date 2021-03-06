"""Add user_passwordhistory, anchore_config tables, and  user_password_change_insert triggers

Revision ID: 3828e380de20
Revises: ea2739ecd874
Create Date: 2018-08-28 16:31:32.570755

"""

# revision identifiers, used by Alembic.

revision = '3828e380de20'
down_revision = 'ea2739ecd874'

from alembic import op
import sqlalchemy as sa

# Postgres triggers for maintaining user password history

fn_userpw_hist = sa.DDL("""
create or replace function user_password_change_insert()
  returns trigger
language plpgsql
as $$
BEGIN
IF
	TG_OP = 'UPDATE' 
	AND OLD."password" <> NEW."password" THEN
	INSERT INTO user_passwordhistory ( user_id, "password" )
VALUES
	( OLD.ID, OLD."password" );
ELSIF ( TG_OP = 'INSERT' ) THEN
INSERT INTO user_passwordhistory ( user_id, "password" )
VALUES
	( NEW.ID, NEW."password" );
END IF;
RETURN NEW;

END;

$$;
""")

trig_userpw_hist_insert = sa.DDL("""

create trigger user_password_insert_trigger
	after insert
	on "user"
	for each row
	execute procedure user_password_change_insert()
;
""")

trig_userpw_hist_change = sa.DDL("""

create trigger user_password_change_insert_trigger
	before update
	on "user"
	for each row
	execute procedure user_password_change_insert()
;
""")


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('anchore_config',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('name', sa.String(length=64), nullable=False),
    sa.Column('username', sa.String(length=64), nullable=True),
    sa.Column('password', sa.String(length=64), nullable=True),
    sa.Column('url', sa.String(length=1024), nullable=True),
    sa.Column('ssl_verify', sa.Boolean(), nullable=True),
    sa.PrimaryKeyConstraint('id', 'name')
    )
    op.create_table('user_passwordhistory',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('user_id', sa.Integer(), nullable=False),
    sa.Column('password', sa.String(length=255), nullable=True),
    sa.Column('changed_at', sa.DateTime(), server_default=sa.func.current_timestamp()),
    sa.ForeignKeyConstraint(['user_id'], ['user.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_user_passwordhistory_user_id', 'user_passwordhistory', ['user_id'], unique=False)
    # ### end Alembic commands ###

    # Create User Password History related triggers
    ddl_callable_fn = fn_userpw_hist.execute_if(dialect="postgresql")
    ddl_callable_fn(target=None, bind=op.get_context().bind)
    ddl_callable_trig_ins = trig_userpw_hist_insert.execute_if(dialect="postgresql")
    ddl_callable_trig_ins(target=None, bind=op.get_context().bind)
    ddl_callable_trig_chg = trig_userpw_hist_change.execute_if(dialect="postgresql")
    ddl_callable_trig_chg(target=None, bind=op.get_context().bind)

    # Build Password History record for current users
    conn = op.get_bind()
    conn.execute(sa.sql.text('''
        INSERT INTO user_passwordhistory(user_id, password, changed_at)  select "user".id as user_id, password, current_timestamp - interval '61 days' from "user";
        '''))

def downgrade():
    conn = op.get_bind()
    conn.execute(sa.sql.text('''
    DROP TRIGGER IF EXISTS user_password_insert_trigger ON "user";
    DROP TRIGGER IF EXISTS user_password_change_insert_trigger ON "user";
    DROP FUNCTION IF EXISTS user_password_change_insert();
        '''))
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_index('ix_user_passwordhistory_user_id', table_name='user_passwordhistory')
    op.drop_table('user_passwordhistory')
    op.drop_table('anchore_config')
    # ### end Alembic commands ###
